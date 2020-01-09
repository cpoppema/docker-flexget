# cpoppema/docker-flexget

[![Build Status](https://img.shields.io/docker/build/cpoppema/docker-flexget.svg)](https://hub.docker.com/r/cpoppema/docker-flexget/builds)
[![Image Size](https://img.shields.io/microbadger/image-size/cpoppema/docker-flexget.svg?style=flat&color=blue)](https://hub.docker.com/r/cpoppema/docker-flexget)
[![Docker Stars](https://img.shields.io/docker/stars/cpoppema/docker-flexget.svg?style=flat&color=blue)](https://registry.hub.docker.com/v2/repositories/cpoppema/docker-flexget/stars/count/)
[![Docker Pulls](https://img.shields.io/docker/pulls/cpoppema/docker-flexget.svg?style=flat&color=blue)](https://registry.hub.docker.com/v2/repositories/cpoppema/docker-flexget/)
[![Docker Automated build](https://img.shields.io/docker/automated/cpoppema/docker-flexget.svg?maxAge=2592000&style=flat&color=blue)](https://github.com/cpoppema/docker-flexget/)
[![Buy Me A Coffee](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://www.buymeacoffee.com/cpoppema)

Read all about FlexGet [here](http://www.flexget.com/#Description).

If you do not have a configuration already, you can look around starting off with something like this [config.yml](https://github.com/cpoppema/docker-flexget/blob/master/sample_config.yml):
```
web_server: yes

schedules:
  - tasks: '*'
    interval:
      minutes: 1

tasks:
  test task:
    rss: http://myfavoritersssite.com/myfeed.rss
    series:
      - My Favorite Show
```
Put this file in your data/config folder as `config.yml`.

For a much better FlexGet config.yml example take a look at the bottom of [this page](http://flexget.com/Cookbook/Series/SeriesPresetMultipleRSStoTransmission).

## Note

Recently the python version inside this image had to be upgraded from 2.x to 3.x, this might result in this error message:

```
INFO     scheduler                     Starting scheduler
INFO     apscheduler.scheduler                 Scheduler started
ERROR    apscheduler.jobstores.default                 Unable to restore job "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -- removing it
Traceback (most recent call last):
  File "/usr/lib/python3.7/site-packages/apscheduler/jobstores/sqlalchemy.py", line 141, in _get_jobs
    jobs.append(self._reconstitute_job(row.job_state))
  File "/usr/lib/python3.7/site-packages/apscheduler/jobstores/sqlalchemy.py", line 125, in _reconstitute_job
    job_state = pickle.loads(job_state)
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe3 in position 1: ordinal not in range(128)
```

This is supposedly safe to ignore and should only happens once. If not, let me [know](https://github.com/cpoppema/docker-flexget/issues).

## Usage

```
docker create \
    --name=flexget \
    -e PUID=<uid> \
    -e PGID=<gid> \
    -e WEB_PASSWD=yourhorriblesecret \
    -e TORRENT_PLUGIN=transmission \
    -e TZ=Europe/London \
    -e FLEXGET_LOG_LEVEL=debug \
    -p 5050:5050 \
    -v <path to data>:/config \
    -v <path to downloads>:/downloads \
    cpoppema/docker-flexget
```

For shell access whilst the container is running do `docker exec -it flexget /bin/bash`.

**Parameters**

* `-e PUID` for UserID - see below for explanation
* `-e PGID` for GroupID - see below for explanation
* `-e WEB_PASSWD` for the Web UI password - see below for explanation
* `-e TORRENT_PLUGIN` for the torrent plugin you need, e.g. "transmission" or "deluge"
* `-e TZ` for timezone information, e.g. "Europe/London"
* `-e FLEXGET_LOG_LEVEL` for logging level - see below for explanation
* `-e PIP_REQUIREMENTS_FILE` to either add neccessary packages for plugins _or_ to pin e.g. FlexGet to a certain version until you have time to migrate your configuration because they might be incompatible.
* `-p 5050` for Web UI port - see below for explanation
* `-v /config` - Location of FlexGet config.yml (DB files will be created on startup and also live in this directory)
* `-v /downloads` - location of downloads on disk

**Torrent plugin: Transmission**

FlexGet is able to connect with transmission using `transmissionrpc`, which is installed as the default torrent plugin in this container. For more details, see http://flexget.com/wiki/Plugins/transmission.

Please note: This Docker image does NOT run Transmission. Consider running a [Transmission Docker image](https://github.com/linuxserver/docker-transmission/) alongside this one.

For transmission to work you can either omit the `TORRENT_PLUGIN` environment variable or set it to "transmission".

**Torrent plugin: Deluge**

FlexGet is also able to connect with deluge using `deluge-common`, which can be installed in this container, replacing the transmission plugin. For more details, see https://www.flexget.com/Plugins/deluge.

Please note: This Docker image does NOT run Deluge. Consider running a [Deluge Docker image](https://hub.docker.com/r/linuxserver/deluge/) alongside this one.

For deluge to work you need to set `TORRENT_PLUGIN` environment variable to "deluge".

**Daemon mode**

This container runs flexget in [daemon mode](https://flexget.com/Daemon). This means by default it will run your configured tasks every hour after you've started it for the first time. If you want to run your tasks on the hour or at a different time, look at the [scheduler](https://flexget.com/Plugins/Daemon/scheduler) plugin for configuration options. Configuration is automatically reloaded every time just before starting the tasks as scheduled, to apply your changes immediately you will need to restart the container.

**Web UI**

FlexGet is able to host a Web UI if you have this enabled in your configuration file. See [the wiki](https://flexget.com/wiki/Web-UI) for all details. To get started, simply add:

```
web_server: yes
```

The Web UI is protected by a login, you need to either set the `WEB_PASSWD` environment variable or setup a user after starting this docker:

Connect with the running docker:

```
docker exec -it flexget bash
```

If your configuration file is named "config.yml" you can setup a password like this:

```
flexget -c /config/config.yml web passwd <some_password>
```

Now you can open the Web UI at `http://<ip-of-the-machine-running-docker>:5050` and login with this password, use `flexget` as your username.

Note: if you ever change your password in a running container, don't worry. Recreating or restarting your container will not simply overwrite your new password. If you want to reset your password to the value in `WEB_PASSWD` you can simply remove the `.password-lock` file in your config folder.

**Logging Level**

Set the verbosity of the logger. Optional, defaults to debug if not set. Levels: critical, error, warning, info, verbose, debug, trace.

**Installing additional packages**


Using `-e PIP_REQUIREMENTS_FILE` you can install extra plugin packages you need that are not (yet) baked into this image. If you want to this image to support your plugin out of the box, open an issue to request it or create pull request to add it! Until that's done, here's how you can add packages.

Specifying `-e PIP_REQUIREMENTS_FILE` will install packages *besides* the provided [requirements.txt](https://github.com/cpoppema/docker-flexget/blob/master/requirements.txt).

To get started, create a file `my-requirements.txt` inside your /config directory. Let's say you need `sleekxmpp` for the xmpp notifier system and it is missing from this image. You tell the image where to find it like this:

```
docker create \
    --name=flexget \
    -e PIP_REQUIREMENTS_FILE=/config/my-requirements.txt \
    -v <path to data>:/config \
    -v <path to downloads>:/downloads \
    cpoppema/docker-flexget
```

If you don't like adding files to your /config directory, you can put it anywhere with an extra -v flag:

```
docker create \
    --name=flexget \
    -e PIP_REQUIREMENTS_FILE=/my-requirements.txt \
    -v <path to data>:/config \
    -v <path to downloads>:/downloads \
    -v <path to my-requirements.txt>:/my-requirements.txt \
    cpoppema/docker-flexget
```

**Pinning packages or FlexGet**

To pin packages that are automatically installed you use -v to overwrite `/requirements.txt`:

```
docker create \
    --name=flexget \
    -v <path to data>:/config \
    -v <path to downloads>:/downloads \
    -v <path to version pinned requirements.txt>:/requirements.txt \
    cpoppema/docker-flexget
```

If you want to pin packages that are not automatically installed, you can follow the instructions above and [put the versions](https://pip.pypa.io/en/stable/user_guide/#pinned-version-numbers) you want in `my-requirements.txt`.

### User / Group Identifiers

**TL;DR** - The `PGID` and `PUID` values set the user / group you'd like your container to 'run as' to the host OS. This can be a user you've created or even root (not recommended).

Part of what makes this container work so well is by allowing you to specify your own `PUID` and `PGID`. This avoids nasty permissions errors with relation to data volumes (`-v` flags). When an application is installed on the host OS it is normally added to the common group called users, Docker apps due to the nature of the technology can't be added to this group. So this feature was added to let you easily choose when running your containers.

[Flexget CLI](https://flexget.com/CLI)

## Updates / Monitoring

* Upgrade to the latest version of FlexGet simply `docker restart flexget`.
* Monitor the logs of the container in realtime `docker logs -f flexget`.

**Credits**
* [linuxserver.io](https://github.com/linuxserver) for providing awesome docker containers.
