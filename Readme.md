# Marauder

This is designed to be a fully dockerized Media downloading + Watching solution utilising Google Drive as an unlimited disk backend. 

## Getting Started

Check out the "Getting Started" page [here](https://github.com/Makeshift/Marauder/wiki/Getting-Started). This should be enough to get you going.

**The documentation is still under construction and is subject to change! If you have any questions in the meantime, please open an issue.**

## Features

- Very, very fast. I regularly download & watch 100+GB 4K movies from the Plex server with no issues.
- Automatically gets around the 750GB/day upload limit, and 400,000 file limit in Google Drive by switching between service accounts and team drives.
- All in one place. If you need to delete everything, or back everything up, you're just dealing with one folder.
- Has all the random software and stuff you'll need (Well, I'm working on it).
- Walks you through various optimisations to make your life easier.
- Requires little to no maintenance once configured.
- Doesn't destroy your disk IO by trying to move giant files between docker volumes.

## Motivation

There are several other attempts at this, such as [Cloudbox](https://github.com/Cloudbox/Cloudbox) and [PGBlitz](https://github.com/PGBlitz/PGBlitz.com), however I found these setups a little lacking in certain areas.

- They require an entire VM or machine dedicated to it
- They aren't _fully_ dockerized, it mangles the host machine and places config/installation all over the place, making it difficult to back up or fully utilise machine resources
- They regularly have rookie mistakes such as moving data between two Docker volumes, causing unneccessary high disk I/O
- They make too many assumptions about your current setup, and make it difficult to change (Well, so does mine, but it's __my__ setup so I'm allowed to be a hypocrite)

This setup has one gigantic shared folder named `shared`. It's set up with Rclone union mounts so that programs like Sonarr, Radarr, Medusa etc. all believe that the downloading and gdrive media directories are on the same filesystem (because they are!). This severely reduces I/O compared to moving things between volumes. There's then some clever volume mapping so all the programs have matched up directories even though they're technically pointed to different places.

## FAQ

**Q: How much RAM/CPU/Disk space do I need?**
**A:** This is hard to say. I have 32gb on my VM, but I also have a much larger collection than most so Rclone uses a lot of RAM. Rclone has fairly high limits in its current setup so may run out of memory on machines with less than 16gb - I may include some options to reduce that if needed.

In terms of CPU, it depends on how much you're downloading and whether you're using usenet or torrenting. I wouldn't advise using a Pi 1 for it, but it might run okay on a Pi 4 if you're only downloading a couple films a week or something.

For disk space, you need space to store incomplete downloads and cache them before they're downloaded, so it depends on what you're downloading.

**Q: Why are most of the containers on the host network?**

**A:** You'd be surprised how much CPU a bandwith-heavy container can use using the Docker proxy (especially for something like Sabnzbd). It just makes sense to allow the heavy stuff to bridge straight to the host, which also comes with its own set of connectivity challenges. Also, each open port would be a proxy process, so having a large range for torrenting would suck.

**Q: How do I disable some of the services I don't want/need?**

**A:** The easiest way would probably choose the services you want when you're starting the stack. Some of them have dependants, so if you choose `sonarr` you will get `rclone` by default as well, but you can customise which ones you want:
```bash
docker compose up -d sonarr radarr headphones transmission
```
Alternatively, you can also just comment out the services you don't want in the `docker-compose.yml` file. This may be a more convenient solution for some.

**Q: There are some extra settings in the service interface that you don't mention! What do I do?!**

**A:** That's intentional. The defaults for whatever I don't mention are usually fine. If I included all of the config options, it would take too long to configure.

**Q: Why is there a custom version of Traktarr/Bazarr?**

**A:** Traktarr/Bazarr times out listing movies/TV after 30/60 seconds. I edit it so it times out after 5 minutes instead. My library is big, and the Sonarr/Radarr APIs lag like crazy when they're doing _anything_.

**Q: Why Plex as opposed to Emby/Jellyfin/Serviio/Whatever?**

**A:** Jellyfin's Chromecast support is iffy at best, especially with subtitles (I watch anime on my Chromecast, deal with it). Emby has similar issues with casting and subtitles but is probably otherwise the least-worst offering. Serviio is a little feature bare. Plex, as much hacking as it requires to get to work, and as *absolutely freaking terrible* as its new interface is, does work once it's set up properly, and handles the abuse I throw at it fairly well.

**Q: Wait, you automatically switch team drives? Won't that cause duplicates?**

**A:** Nope, I fixed that in #4.

## Wiki
Pretty much all documentation has been moved to [the wiki](https://github.com/Makeshift/Marauder/wiki).

## Todo

### Major

- [x] Usenet support
- [ ] Torrent support

### Services:

- [x] Rclone
- [x] NZBHydra2
- [x] Radarr
- [x] Sonarr
- [x] Sabnzbd
- [x] Traktarr
- [x] Medusa
- [x] Headphones
- [x] LazyLibrarian
- [x] Mylar
- [x] Bazarr
- [x] Transmission
- [ ] Jackett
- [x] Plex
- [ ] Tautulli
- [ ] Ombi

### Remote-Control:

- [ ] Radarr Telegram Bot
- [ ] Sonarr Telegram Bot
- [ ] Ombi

### Documentation:

- [x] Readme
- [x] Env Setup
- [x] rclone
- [x] NZBHydra2
- [x] Radarr
- [x] Sonarr
- [x] Sabnzbd
- [x] Traktarr
- [x] Medusa
- [x] Headphones
- [x] LazyLibrarian
- [x] Mylar
- [x] Bazarr
- [ ] Radarr Telegram Bot
- [ ] Sonarr Telegram Bot
- [x] Backing Up
- [ ] Transmission
- [ ] Jackett
- [ ] Plex
- [x] Advanced Plex
- [ ] Tautulli
- [ ] Ombi

### Extras:

- [ ] Intelligently handle torrents and clean up stuff that isn't downloading properly
