#!/bin/bash
#
# Sign an unsigned Pocket Poster IPA with an Apple Distribution certificate
# and an ad-hoc provisioning profile that contains App Groups.
#
# Usage:
#   ./sign_personal.sh <unsigned.ipa> <cert.p12> <p12-password> <profile.mobileprovision> [output.ipa]
#
set -euo pipefail

if [ $# -lt 4 ]; then
    echo "usage: $0 <unsigned.ipa> <cert.p12> <p12-password> <profile.mobileprovision> [output.ipa]" >&2
    exit 64
fi

IPA="$1"
P12="$2"
P12_PASS="$3"
PROFILE="$4"
OUT="${5:-$(pwd)/Pocket_Poster-personal.ipa}"

for f in "$IPA" "$P12" "$PROFILE"; do
    [ -f "$f" ] || { echo "missing file: $f" >&2; exit 66; }
done

WORK="$(mktemp -d "${TMPDIR:-/tmp}/pocket-sign.XXXXXX")"
KC_NAME="pocket-sign-$$-$(date +%s)"
KC_PATH="$HOME/Library/Keychains/$KC_NAME-db"
KC_PASS="$(uuidgen)"

ORIG_DEFAULT="$(security default-keychain -d user | sed -e 's/^ *"//' -e 's/"$//')"
ORIG_KC_LIST=()
while IFS= read -r line; do
    line="$(echo "$line" | sed -e 's/^ *"//' -e 's/"$//')"
    [ -n "$line" ] && ORIG_KC_LIST+=("$line")
done < <(security list-keychains -d user)

cleanup() {
    set +e
    if [ -n "${ORIG_DEFAULT:-}" ]; then
        security default-keychain -d user -s "$ORIG_DEFAULT" >/dev/null 2>&1
    fi
    if [ ${#ORIG_KC_LIST[@]} -gt 0 ]; then
        security list-keychains -d user -s "${ORIG_KC_LIST[@]}" >/dev/null 2>&1
    fi
    security delete-keychain "$KC_NAME" >/dev/null 2>&1
    rm -rf "$WORK"
}
trap cleanup EXIT

echo "[*] Creating temporary keychain"
security create-keychain -p "$KC_PASS" "$KC_NAME"
security set-keychain-settings -lut 21600 "$KC_NAME"
security unlock-keychain -p "$KC_PASS" "$KC_NAME"

echo "[*] Importing signing identity"
# Security.framework's PKCS#12 importer rejects this (legacy-encoded) p12,
# so convert it to an unencrypted PEM bundle and import that instead.
openssl pkcs12 -in "$P12" -passin "pass:$P12_PASS" -nodes -out "$WORK/identity.pem" >/dev/null 2>&1
security import "$WORK/identity.pem" -k "$KC_NAME" -T /usr/bin/codesign >/dev/null

# Bring the WWDR intermediate into the temporary keychain so codesign can
# embed the full chain.
{
    security find-certificate -a -c "Apple Worldwide Developer Relations" -p "$HOME/Library/Keychains/login.keychain-db" 2>/dev/null
    security find-certificate -a -c "Apple Worldwide Developer Relations" -p /Library/Keychains/System.keychain 2>/dev/null
} > "$WORK/wwdr.pem"
if [ -s "$WORK/wwdr.pem" ]; then
    security import "$WORK/wwdr.pem" -k "$KC_NAME" >/dev/null 2>&1 || true
fi

security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KC_PASS" "$KC_NAME" >/dev/null
security default-keychain -d user -s "$KC_PATH"
security list-keychains -d user -s "$KC_PATH" "${ORIG_KC_LIST[@]}"
security unlock-keychain -p "$KC_PASS" "$KC_NAME"

IDENTITY="$(security find-identity -v -p codesigning | awk '/Apple Distribution|Apple Development/ {print $2; exit}')"
if [ -z "${IDENTITY:-}" ]; then
    echo "no code signing identity found in $P12" >&2
    security find-identity -v -p codesigning >&2
    exit 65
fi
echo "[*] Identity: $IDENTITY"

echo "[*] Extracting provisioning profile"
security cms -D -i "$PROFILE" > "$WORK/profile.plist"
plutil -extract Entitlements xml1 -o "$WORK/entitlements.plist" "$WORK/profile.plist"

APP_ID="$(/usr/libexec/PlistBuddy -c 'Print :application-identifier' "$WORK/entitlements.plist")"
BUNDLE_ID="${APP_ID#*.}"
if [ -n "${BUNDLE_ID_OVERRIDE:-}" ]; then
    BUNDLE_ID="$BUNDLE_ID_OVERRIDE"
fi
echo "[*] Bundle ID: $BUNDLE_ID"

echo "[*] Unpacking IPA"
ditto -x -k "$IPA" "$WORK/unpacked"
APP="$(find "$WORK/unpacked/Payload" -maxdepth 1 -name '*.app' -type d | head -1)"
[ -n "${APP:-}" ] && [ -d "$APP" ] || { echo "no .app inside IPA" >&2; exit 66; }
echo "[*] App: $(basename "$APP")"

/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" "$APP/Info.plist"
cp "$PROFILE" "$APP/embedded.mobileprovision"

echo "[*] Signing"
codesign --force --sign "$IDENTITY" \
    --entitlements "$WORK/entitlements.plist" \
    --timestamp=none \
    "$APP"

echo "[*] Verifying"
codesign --verify --deep --strict --verbose=2 "$APP"
codesign -d --entitlements :- "$APP" 2>/dev/null | plutil -p - | grep -A6 "com.apple.security.application-groups" || true

echo "[*] Packaging"
rm -f "$OUT"
mkdir -p "$WORK/out/Payload"
ditto "$APP" "$WORK/out/Payload/$(basename "$APP")"
( cd "$WORK/out" && zip -qry "$OUT" Payload )

echo "[*] Wrote $OUT"
ls -lh "$OUT"
