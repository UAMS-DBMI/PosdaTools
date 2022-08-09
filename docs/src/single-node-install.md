This is the install guide for Posda, for a single-node installation. 
This type of install is good for a small site, or for a development or testing
installation. Other documentation is available for multi-node installs.

## Prerequisites

### Host OS
Posda is distributed as a set of [Docker](https://www.docker.com) containers,
which means that it will technically work on any platform Docker supports
(including Windows, MacOS, and Linux). However, we _highly_ recommend Linux be 
used for the best compatibility. 

Any Linux distribution should work, though
we have tested Posda on the following:

* Ubuntu 16.04, 18.04, 20.04
* RHEL 7
* CentOS 7

We also have some users successfully running on the latest MacOS, as well as
Windows 10. If you choose to use Windows, there may be some additional
complications. Using WSL 2 will yield the best results.

### Software requirements
* [Docker](#install-docker)
* git
* bash
* Unrestricted access to DockerHub

### Hardware requirements

#### Recommended
* vCPUs: 16
* Memory: 16 GiB
* Storage: 1 TiB

## Steps

* [Clone the Repo](#clone-oneposda)
* [Configure Common Settings](#configure-common-settings)
* [Start Posda](#start-posda)

Once started, see the [post install](#post-install) notes.


### Clone Oneposda
Note: If you received the source as a zip file, unzip it and skip the clone
operation below.

Choose an installation directory, and open a terminal to that location, then
type:

```bash
git clone https://code.imphub.org/scm/pt/oneposda.git
```

You can place this directory anywhere you like, however we recommend placing it
in a location owned by a dedicated user (or root). Any admin working on
this installation will need access to this directory, so it may not make sense
for it to be owned by a normal user.

After it has finished downloading move into the directory and initialize your 
configuration (this will also download the docker containers).

```bash
cd oneposda
./init
```

### Configure Common Settings
There are a number of .env configuration files (now present in the base
directory), but the defaults are usually acceptable for most users.

There is one setting that should be updated if you intend to access this
service from any other computers: `POSDA_EXTERNAL_HOSTNAME`, which can be
found in the `common.env` file. This should be set tot he hostname where users
will expect to find this server. It is set to localhost by default, which will
be sufficient for testing or development.

#### Other settings
There are some other settings that can be adjusted in advanced situations, but
for a default install nothing needs to be changed. If you look in the 
`docker-compose.yaml` file, there are additional comments explaining what each
section is and what it controls. 

### Start Posda
The first time you start Posda, you will want to start the `db` and `posda`
containers first, and wait about 30 seconds after each command for
initial setup to complete.

From the `oneposda` directory, execute:

```bash
./manage up -d db
# Wait 30 seconds for the database to start
./manage up -d posda
# Wait 30 seconds for initial setup to complete
./manage up -d
```

### Post Install

Once all containers are started, go to [http://localhost/](http://localhost/), 
and click on Posda Login. The default username is `admin` and the default
password is `admin`. Once logged in you can change this password by clicking
on __Password__ on the left.


## Misc

## Install Docker
Installing Docker is beyond the scope of this documentation. You can find
further information at the [Docker Homepage](https://docs.docker.com/install/).

Make sure you also install the `compose` plugin (included with Docker Desktop,
may need to be manually installed with the server version).

We recommend Docker Community Edition __version 20.10.17__ or greater, 
and __compose v2.0.1__ or greater.
