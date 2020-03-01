# The Media Compose Stack

This is designed to be a fully dockerized Media downloading solution utilising Google Drive as an unlimited disk backend. 

This particular repo does not contain the media watching/distribution stack. Once I've cleaned that up for release, there will be a link to it here.

## Motivation

There are several other attempts at this, such as [Cloudbox](https://github.com/Cloudbox/Cloudbox) and [PGBlitz](https://github.com/PGBlitz/PGBlitz.com), however I found these setups a little lacking in certain areas.

- They require an entire VM or machine dedicated to it
- They aren't _fully_ dockerized, it mangles the host machine and places config/installation all over the place, making it difficult to back up or fully utilise machine resources
- They regularly have rookie mistakes such as moving data between two Docker volumes, causing unneccessary high disk I/O
- They make too many assumptions about your current setup, and make it difficult to change

This setup has one gigantic shared folder named `shared`. It's set up with Rclone union mounts so that programs like Sonarr, Radarr, Medusa etc. all believe that the downloading and gdrive media directories are on the same filesystem (because they are!). This severely reduces I/O compared to moving things between volumes. There's then some clever volume mapping so all the programs have matched up directories even though they're technically pointed to different places.

## FAQ

**Q: Why are most of the containers on the host network?**
**A:** You'd be surprised how much CPU a bandwith-heavy container can use using the Docker proxy (especially for something like Sabnzbd). It just makes sense to allow the heavy stuff to bridge straight to the host, which also comes with its own set of connectivity challenges. Also, each open port would be a proxy process, so having a large range for torrenting would suck.

**Q: How do I disable some of the services I don't want/need?**
**A:** The easiest way would probably choose the services you want when you're starting the stack. Some of them have dependants, so if you choose `sonarr` you will get `rclone` by default as well, but you can customise which ones you want:
```bash
docker compose up -d sonarr radarr headphones transmission
```
Alternatively, you can also just comment out the services you don't want in the `docker-compose.yml` file. This may be a more convenient solution for some.

**Q: Why Plexdrive AND Rclone?**
**A:** Rclone by itself had some issues with caching, especially when it comes to larger collections, so we union it with Plexdrive for faster response time. If you've ever tried to import 3000 films to Radarr from Google Drive, you know the pain.

**Q: Why do you use an Rclone union plugin rather than the normal one?**
**A:** The plugin I include with the Rclone container is actually the standard Rclone union plugin with exactly one line changed:
```go
var remote = f.remotes[len(f.remotes)-i-1]
// became
var remote = f.remotes[i]
```
This means that with our current reverseunion mount `/shared/separate plexdrive: encryptedgdrive:` it will return the answer from plexdrive first, which resolves much faster than gdrive. This makes seeking and some other actions significantly faster.
This DOES mean that there is a chance that the mount will return outdated information in the case of replacing/updating/deleting a file (Due to it writing to `encryptedgdrive` but reading from the cached `plexdrive`), but I believe in this particular use case it doesn't matter that much.

**Note:** I'm actually not sure if my added Plexdrive + plugin actually does anything anymore. It certainly used to, but Rclone's caching is now a lot better than it used to be. I have no decent side-by-side testing so I'm going to keep it as-is for now, but may remove Plexdrive + ReverseUnion later.

## Configuration and deployment

### Pre-Setup

You will need:
- A Linux machine (I use Ubuntu 18.04 LTS)
- Docker (19.03.6+) + Docker Compose (1.17.1+)
- Some Rclone knowledge (Possibly a previous setup as well to copy files from)
- A Plexdrive setup to copy files from (Optional - will work without)
- A Google Drive account with unlimited storage
- A [Google Drive service account](https://rclone.org/drive/#service-account-support)
- Encryption [set up already](https://rclone.org/crypt/) in Google Drive
- The compose file has labels compatible with my [Docker Nginx Conf Generator](https://github.com/Makeshift/docker-generate-nginx-conf), but it isn't neccessary

```bash
git clone github.com/Makeshift/Media-Compose-Stack
```

### Secrets & Env Vars
#### Top-Level

If you intend to use my [Docker Nginx Conf Generator](https://github.com/Makeshift/docker-generate-nginx-conf), you can set your domain name in the top level `.env` file.

```bash
cp .env.template .env
```
`domain=example.com`

#### Rclone

There are several env vars required to get Rclone to work. Here are the vars and where you can get them:

| Var                               | Source                                                                                | Notes                                                                                                                                                                      |
|--------------------------------   |-----------------------------------------------------------------------------------    |--------------------------------------------------------------------------------------------------------------------                                                        |
| rclone_encryption_password1       | [Rclone Crypt Config](https://rclone.org/crypt/)                                      | If you've previously set up Rclone, this will be in `~/.config/rclone/rclone.conf` under config param `password`                                                           |
| rclone_encryption_password2       | [Rclone Crypt Config](https://rclone.org/crypt/)                                      | If you've previously set up Rclone, this will be in `~/.config/rclone/rclone.conf` under config param `password2`                                                          |
| rclone_gdrive_token               | [Rclone Gdrive Config](https://rclone.org/drive/)                                     | If you've previously set up Rclone, this will be in `~/.config/rclone/rclone.conf` under config param `token`                                                              |
| rclone_gdrive_impersonate         | Google Drive Owner's Email Address                                                    | This is the email address that the service account will be impersonating to access Google Drive                                                                            |
| rclone_service_credential_file    | [Google Drive Service Account](https://rclone.org/drive/#service-account-support)     | Open the file and use [a JSON minifier](https://www.cleancss.com/json-minify/) to minify the JSON to keep your envfile readable.                                           |
| rclone_gdrive_mount_folder        | If your crypt directory is not the top level of Gdrive, this is the encrypted folder  | My GDrive is set up with Rclone encrypting the top level folder `encrypted`, so my mount folder is simply `encrypted`.                                                     |
| plexdrive_config_file             | Configure [Plexdrive](https://github.com/dweidenfeld/plexdrive)                       | If you've previously set up Plexdrive, this will be in `~/.config/plexdrive/config.json`. Use [a JSON minifier](https://www.cleancss.com/json-minify/) to minify the JSON. |
| plexdrive_token_file              | Configure [Plexdrive](https://github.com/dweidenfeld/plexdrive)                       | If you've previously set up Plexdrive, this will be in `~/.config/plexdrive/token.json`. Use [a JSON minifier](https://www.cleancss.com/json-minify/) to minify the JSON.  |

Remember that you *do not* need to escape the variables in env files.

```bash
cp rclone/secrets.env.template rclone/secrets.env
```

### Starting the Stack

Starting the stack should be as simple as
```bash
docker-compose up -d ; docker-compose logs -f
```
I advise the above command as it will disconnect you from the containers after it finishes building them, but still allows you to follow logs to watch for errors. `Ctrl+C` will not kill the running containers, just kill the log follow.

In case of a problem, you can run
```bash
docker-compose down
```
to clean up the stack. This will not delete any configuration.

#### Plexdrive (Optional) 

If you are using Plexdrive as well as Rclone, it will need to process your entire Google Drive before it starts providing benefit. Keep an eye on the logs (`docker-compose logs -f`). I advise not continuing setup until Plexdrive is finished.
When the logs says `First cache build process finished!`, that's when it's done processing.

At this point, you should restart the stack to ensure Plexdrive is correctly mounted
```bash
docker-compose restart ; docker-compose logs -f
```

#### Pre-Warming Rclone (Optional)

Whether you are using Plexdrive or not, it may be worth pre-warming the Rclone caches with data.
Go to `shared/merged/Media` (or whichever folder your Media lies in) and run:
```bash
ls -R . > /dev/null &;disown
```
You can continue using the remote while this happens, it will simply `ls` through every folder in your remote to warm the caches (and will disown it so it keeps going even if you kill your session).

### Service Configuration

#### NZBHydra2
NZBHydra2 is a searching/caching/indexing tool for Newznab and Torznab indexers. It acts as a proxy in between sources of NZBs and your services, which means less configuration down the line.

You'll only need this if you plan to use this stack with Usenet.

- Connect to the Web UI on port `5076`.
- Follow the Web UI guide to add your indexers
- Click the `Config` button
- Click the `API?` button on the right hand side. Note down your API key.

#### Sabnzbd
Sabnzbd is used to download from Usenet. You'll need Usenet account(s).

- On your host, run `chmod -R 777 shared/separate/sabnzbd`
- Connect to the Web UI on port `8080`.
- Follow the quick-start wizard
- Click the cog at the top right

**In the `General` tab**

- Note down your API Key

**In the `Folders` tab**

| Setting Name                                      | Value                                                                                         |
|-------------------------------------------------- |---------------------------------------------------------------------------------------------- |
| Temporary Download Folder                         | `/shared/merged/downloads/sabnzbd/incomplete`                                                 |
| Minimum Free Space for Temporary Download Folder  | A reasonable number, I chose 300GB on a 2TB disk                                              |
| Completed Download Folder                         | `/shared/merged/downloads/sabnzbd/default/` (We'll be overriding this with categories later)  |
| Permissions for completed downloads               | 777                                                                                           |

**In the `Categories` tab**
Copy the below table:

| Category          | Priority  | Processing    | Script    | Folder/Path           | Indexer Categories/Groups     |
|---------------    |---------- |------------   |--------   |--------------------   |---------------------------    |
| Default           | Normal    | +Delete       |           |                       |                               |
| sonarr            | Default   | Default       |           | `../sonarr`           |                               |
| headphones        | Default   | Default       |           | `../headphones`       |                               |
| radarr            | Default   | Default       |           | `../radarr`           |                               |
| lazylibrarian     | Default   | Default       |           | `../lazylibrarian`    |                               |
| medusa            | Default   | Default       |           | `../medusa`           |                               |
| mylar             | Default   | Default       |           | `../mylar`            |                               |

#### Transmission
Todo

#### Radarr

- Navigate to the web UI on port `7878`
- Navigate to the `Settings` page

**In the `Media Management` tab**

The movie and folder formats were chosen to make importing easier in the case of losing the Radarr database. However, they are fairly optional.

| Setting Name                      | Value                                                                                                                                      |
|-------------------------------    |---------------------------------                                                                                                           |
| **Movie Naming**                  |                                                                                                                                            |
| Rename Movies                     | Yes                                                                                                                                        |
| Replace Illegal Characters        | Yes                                                                                                                                        |
| Colon Replacement Format          | Replace with Space Dash Space                                                                                                              |
| Standard Movie Format             | `{Movie Title} ({Release Year}) ({IMDb Id}) {{Quality Full}}`                                                                              |
| Movie Folder Format               | `{Movie TitleThe} ({Release Year}) ({IMDb Id})`                                                                                            |
| **Folders**                       |                                                                                                                                            |
| Automatically Rename Folders      | (Optional - May be a bad idea if you have a large collection that doesn't currently follow the above folder format) Yes                    |
| **Importing**                     |                                                                                                                                            |
| Skip Free Space Check             | Yes                                                                                                                                        |
| Use Hardlinks instead of Copy     | No                                                                                                                                         |
| Import Extra Files                | Yes                                                                                                                                        |
| Extra File Extensions             | `srt,nfo`                                                                                                                                  |
|                                   |                                                                                                                                            |

**In the `Indexers` tab**
- Press the `+` to add a new indexer
- Click `Newznab`

| Setting Name  | Value                                             |
|-------------- |------------------------------------------------   |
| Name          | NZBHydra2                                         |
| URL           | `http://localhost:5076`                           |
| API Key       | The key you noted down in the NZBHydra section    |

**In the `Download Client` tab**
- Press the `+` to add a new download client
- Click 'SABnzbd'

| Setting Name  | Value                                                 |
|-------------- |-----------------------------------------------------  |
| Name          | SABnzbd                                               |
| Host          | localhost                                             |
| Port          | 8080                                                  |
| API Key       | The API key you noted down from the SABnzbd section   |
| Category      | radarr                                                |

Todo: Transmission

**Add movie library**
- Click 'Add Movies' at the top left
- Either bulk import your current library, or add a new movie to configure the default library. It should be under `/shared/merged`, eg `/sharged/merged/Media/Movies`.

#### Sonarr

- Navigate to the web UI on port `8989`
- Navigate to the `Settings` page

**In the `Media Management` tab**

| Setting Name                      | Value                                                             |
|-------------------------------    |---------------------------------                                  |
| **Episode Naming**                |                                                                   |
| Rename Episodes                   | Yes                                                               |
| Replace Illegal Characters        | Yes                                                               |
| Colon Replacement Format          | Replace with Space Dash Space                                     |
| Standard Episode Format           | `{Series Title} - S{season:00}E{episode:00} - {Episode Title}`    |
| Daily Episode Format              | `{Series Title} - {Air-Date} - {Episode Title}`                   |
| Anime Episode Format              | `{Series Title} - S{season:00}E{episode:00} - {Episode Title}`    |
| **Importing**                     |                                                                   |
| Skip Free Space Check             | Yes                                                               |
| Use Hardlinks instead of Copy     | No                                                                |
| Import Extra Files                | Yes                                                               |
| Extra File Extensions             | `srt,nfo`                                                         |
| **Root Folders**                  | `/shared/merged/Media/TV`                                         |

**In the `Indexers` tab**
- Press the `+` to add a new indexer
- Click `Newznab`

| Setting Name  | Value                                             |
|-------------- |------------------------------------------------   |
| Name          | NZBHydra2                                         |
| URL           | `http://localhost:5076`                           |
| API Key       | The key you noted down in the NZBHydra section    |

**In the `Download Client` tab**
- Press the `+` to add a new download client
- Click 'SABnzbd'

| Setting Name  | Value                                                 |
|-------------- |-----------------------------------------------------  |
| Name          | SABnzbd                                               |
| Host          | localhost                                             |
| Port          | 8080                                                  |
| API Key       | The API key you noted down from the SABnzbd section   |
| Category      | radarr                                                |

Todo: Transmission

## Backing up / Moving

While it may be easier to just `tar` the entire thing to move it (make sure you `docker-compose down` first to unmount gdrive!), sometimes you only want to back up runtime config. Here's an idea of where things are stored and what you should back up.

| File                  | Description                                                                                                           | Back up?  |
|---------------------- |---------------------------------------------------------------------------------------------------------------------- |---------- |
| `.env`                | Contains env vars used in the compose file itself                                                                     | Yes       |
| `rclone/secrets.env`  | Secrets required for Rclone to run                                                                                    | Yes       |
| `rclone/rclone.conf`  | If you've made any tweaks to the mount settings, you might want to back this up                                       | Maybe     |
| `runtime_conf/`       | Contains all the service-specific config generated after first startup and during use                                 | Yes       |
| `shared/separate`     | Individual mounts for downloaders (You can back these up if you care about losing unsorted or in-progress downloads)  | Maybe     |
| `shared/caches`       | Contains Rclone's pre-upload cache, disk caches and Plexdrive caches                                                  | Maybe     |
| `shared/merged`       | Union mount containing Google Drive and merged download directories                                                   | No        |

## Todo
### Services:

- [x] Rclone
- [x] NZBHydra2
- [x] Radarr
- [x] Sonarr
- [x] Sabnzbd
- [ ] Traktarr
- [ ] Medusa
- [ ] Headphones
- [ ] LazyLibrarian
- [ ] Mylar
- [ ] Bazarr
- [ ] Transmission
- [ ] Jackett

### Remote-Control:

- [ ] Radarr Telegram Bot
- [ ] Sonarr Telegram Bot

### Documentation:

- [x] Readme
- [x] Env Setup
- [x] Secrets
- [x] NZBHydra2
- [x] Radarr
- [ ] Sonarr
- [x] Sabnzbd
- [ ] Traktarr
- [ ] Medusa
- [ ] Headphones
- [ ] LazyLibrarian
- [ ] Mylar
- [ ] Bazarr
- [ ] Radarr Telegram Bot
- [ ] Sonarr Telegram Bot
- [x] Backing Up
- [ ] Transmission
- [ ] Jackett