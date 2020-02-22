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

## Configuration and deployment

### Pre-Setup

You will need:
- A Linux machine (I use Ubuntu 18.04 LTS)
- Docker (19.03.6+) + Docker Compose (1.17.1+)
- Some Rclone knowledge
- A Google Drive account with unlimited storage
- A [Google Drive service account](https://rclone.org/drive/#service-account-support)
- Encryption [set up already](https://rclone.org/crypt/) in Google Drive
- The compose file has labels compatible with my [Docker Nginx Conf Generator](https://github.com/Makeshift/docker-generate-nginx-conf), but it isn't neccessary

```bash
git clone github.com/Makeshift/MediaCompose
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

| Var                               | Source                                                                                | Notes                                                                                                                            |
|--------------------------------   |-----------------------------------------------------------------------------------    |--------------------------------------------------------------------------------------------------------------------              |
| rclone_encryption_password1       | [Rclone Crypt Config](https://rclone.org/crypt/)                                      | If you've previously set up Rclone, this will be in `~/.config/rclone/rclone.conf` under config param `password`                 |
| rclone_encryption_password2       | [Rclone Crypt Config](https://rclone.org/crypt/)                                      | If you've previously set up Rclone, this will be in `~/.config/rclone/rclone.conf` under config param `password2`               |
| rclone_gdrive_token               | [Rclone Gdrive Config](https://rclone.org/drive/)                                     | If you've previously set up Rclone, this will be in `~/.config/rclone/rclone.conf` under config param `token`                   |
| rclone_gdrive_impersonate         | Google Drive Owner's Email Address                                                    | This is the email address that the service account will be impersonating to access Google Drive                                  |
| rclone_service_credential_file    | [Google Drive Service Account](https://rclone.org/drive/#service-account-support)     | Open the file and use [a JSON minifier](https://www.cleancss.com/json-minify/) to minify the JSON to keep your envfile readable. |

Remember that you *do not* need to escape the variables in env files.

```bash
cp rclone/secrets.env.template rclone/secrets.env
```

### Starting the Stack

Starting the stack should be as simple as
```bash
docker-compose up -d ; docker-compose logs -f
```
I advise the above command as it will disconnect you from the containers after it finishes building the containers, but still allow you to follow logs.

In case of a problem, you can run
```bash
docker-compose down
```
to clean up the stack. This will not delete any configuration.

### Service Configuration

Todo


## Backing up / Moving

While it may be easier to just `tar` the entire thing to move it (make sure you `docker-compose down` first to unmount gdrive!), sometimes you only want to back up runtime config. Here's an idea of where things are stored and what you should back up.

| File                  | Description                                                                                                           | Back up?  |
|---------------------- |---------------------------------------------------------------------------------------------------------------------- |---------- |
| `.env`                | Contains env vars used in the compose file itself                                                                     | Yes       |
| `rclone/secrets.env`  | Secrets required for Rclone to run                                                                                    | Yes       |
| `runtime_conf/`       | Contains all the service-specific config generated after first startup and during use                                 | Yes       |
| `shared/separate`     | Individual mounts for downloaders (You can back these up if you care about losing unsorted or in-progress downloads)  | Maybe     |
| `shared/merged`       | Union mount containing Google Drive and merged download directories                                                   | No        |

## Todo
### Services:

- [x] Rclone
- [x] Nzbhydra2
- [x] Radarr
- [x] Sonarr
- [x] Sabnzbd
- [ ] Traktarr
- [ ] Medusa
- [ ] Headphones
- [ ] LazyLibrarian
- [ ] Mylar
- [ ] Bazarr

### Remote-Control:

- [ ] Radarr Telegram Bot
- [ ] Sonarr Telegram Bot

### Documentation:

- [x] Readme
- [x] Env Setup
- [x] Secrets
- [ ] Nzbhydra2
- [ ] Radarr
- [ ] Sonarr
- [ ] Sabnzbd
- [ ] Traktarr
- [ ] Medusa
- [ ] Headphones
- [ ] LazyLibrarian
- [ ] Mylar
- [ ] Bazarr
- [ ] Radarr Telegram Bot
- [ ] Sonarr Telegram Bot
- [x] Backing Up