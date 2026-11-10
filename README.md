<div align="center">
   <img width="150" height="150" src="Pocket Poster/Assets.xcassets/AppIcon.appiconset/pocket_poster_transparent.png">
</div>

<div align="center">
  <h1><b>Pocket Poster</b></h1>
  <p><i>Custom PosterBoard Wallpapers for iOS 17+ · worse_query for iOS 26–27.2</i></p>
  <p>Original project by <a href="https://github.com/leminlimez"><b>leminlimez</b></a> · bad_query port by <a href="https://github.com/Mak5er"><b>Mak5er</b></a> · worse_query port by <a href="https://git.jbjflab.top/admin"><b>admin</b></a></p>
</div>

## Origin

This repository is a fork of [**Mak5er/Pocket-Poster**](https://github.com/Mak5er/Pocket-Poster) on GitHub, which in turn is a fork of the original [**leminlimez/Pocket-Poster**](https://github.com/leminlimez/Pocket-Poster). The `worse_query` port, iOS 27.2 support, and the releases published here are maintained by [admin](https://git.jbjflab.top/admin).

## Download

Latest IPA: [**Releases**](https://git.jbjflab.top/admin/Pocket-Poster/releases)

Build an unsigned IPA locally with `./ipabuild.sh`, then sign it with a provisioning profile that includes an **App Group** before installing.

## Getting Started

### iOS 26 / 27.2 (worse_query)
On versions where [worse_query][worseQueryGitHub] works (iOS 26.0–26.7.2 and 27.0–27.2.x), **no computer is required**. The app must be signed with a provisioning profile that contains an **App Group** — worse_query uses that container to place its symlink and obtain the sandbox extension. Signed IPAs produced with the included `sign_personal.sh` already carry the profile's App Groups.

1. Install the IPA (sideload with your signer of choice; the profile needs an App Group).
2. Settings → **Detect On-Device** (or just hit Apply — hash auto-detects).
3. Select tendies / video → **Apply** → device does a **full respring** (Frontboard + Backboard).

If no App Group entitlement is present the app reports it explicitly; on iOS 26 the legacy bad_query route is used as a fallback.

**Reset Collections** wipes PosterBoard descriptors via worse_query, then full resprings the same way.

### Older iOS (legacy .Trash exploit)
You will need a computer to get the App Hash/UUID.

Download [Nugget][NuggetGitHub] on your computer and plug in your phone.
<br>Then, navigate to the `Settings` page and click the `Pocket Poster Helper` button. 
<br>Inside Pocket Poster, click the `Detect` button inside of settings.

Community-made wallpapers can be found on the [official Cowabun.ga site][CowabungaWallpapersPage].
<br>Join the [Cowabunga Discord Server][CowabungaDiscord] for additional help.

## Credits
- **[Mak5er][Mak5erGitHub]** — worse_query integration, iOS 27.2 port, full respring, on-device detect
- [LeminLimez][LeminGitHub] — original Pocket Poster
- Translations crowdsourced using [POEditor][POEditorJoin]
- [PosterRestore][PosterRestoreDiscord] for their help with PosterBoard
- [dootskyre][dootskyreX] for the fallback shortcut
- [Nathan][NathanGitHub] and [DuyKhanhTran][DuyKhanhTranGitHub] for the .Trash exploit
- [forcequitOS][worseQueryGitHub] for worse_query (iOS 26/27 sandbox escape)
- [SerStars][SerStarsX] for creating the website

[CowabungaWallpapersPage]: https://cowabun.ga/wallpapers
[NuggetGitHub]: https://github.com/leminlimez/Nugget
[LeminGitHub]: https://github.com/leminlimez
[Mak5erGitHub]: https://github.com/Mak5er
[CowabungaDiscord]: https://discord.gg/cowabunga
[PosterRestoreDiscord]: https://discord.gg/gWtzTVhMvh

[POEditorJoin]: https://poeditor.com/join/project/MPZOsunwVj
[dootskyreX]: https://x.com/dootskyre
[NathanGitHub]: https://github.com/verygenericname
[DuyKhanhTranGitHub]: https://github.com/khanhduytran0
[SerStarsX]: https://x.com/SerStars
[badQueryGitHub]: https://github.com/forcequitOS/bad_query
[worseQueryGitHub]: https://github.com/forcequitOS/worse_query
