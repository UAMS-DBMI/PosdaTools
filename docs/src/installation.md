This is the installation guide for Posda.

## Things to consider
There are a handful of things you should consider before beginning
installation, such as:

* What host OS will you use?
* What type of installation?
* Will storage be separate?
* Will database be separate?

### Host OS
Posda is distributed as a set of [Docker](https://www.docker.com) containers,
which means that it will technically work on any platform Docker supports
(including Windows, MacOS, and Linux). However, we recommend Linux be used
for the best compatibility. MacOS is the second-best choice, and we discourage
the use of Windows.

Any Linux distribution should work, as long as you can install Docker, though
we have tested Posda on the following:

* Ubuntu 16.04, 18.04
* RHEL 7
* Alpine


### Type of Installation
Posda supports a number of different types of installation. The main options
are if separate storage will be used, and/or a separate database server. The
reasons why you would make these choices are beyond the scope of this
documentation, but you should make those choices before beginning installation.

We have included three example configurations in this guide:

* Small - Single machine, for a small site, or development, or demonstration
* Medium - When separate storage is needed
* Large - When separate storage and database servers are needed


## Install Sizes / Types
Here are three common types of installations, along with a list of which
sections you would need to follow for each.

### Small / Development Installation
This is the appropriate set of sections you would follow to install Posda
on a single machine, such as for development or demonstration purposes,
or just an environment where this is all that is required.


* [Install Docker](#install-docker)
* [Clone the Repo](#clone-oneposda)
* [Configure Common Settings](#configure-common-settings)
* [Start Posda](#start-posda)


### Medium / Separate Storage
* [Install Docker](#install-docker)
* [Clone the Repo](#clone-oneposda)
* Connect storage to Host
* [Configure storage](#configure-storage) in docker-compose.yaml
* [Configure Common Settings](#configure-common-settings)
* [Start Posda](#start-posda)

### Large / Separate Storage and Separate Database
* Provision database server, install PostgreSQL
* [Install Docker](#install-docker)
* [Clone the Repo](#clone-oneposda)
* Connect storage to Host
* [Configure storage](#configure-storage) in docker-compose.yaml
* [Configure database](#configure-database)
* [Configure Common Settings](#configure-common-settings)
* [Start Posda](#start-posda)


## Install Docker
Installing Docker is beyond the scope of this documentation. You can find
further information at the [Docker Homepage](https://docs.docker.com/install/).

Make sure you also install `docker-compose`. Instructions are available at
[Install Docker Compose](https://docs.docker.com/compose/install/).


## Clone Oneposda
First you will need to install `git` on your system. Once you have git, 
simply clone Posda by typing:

```bash
git clone https://code.imphub.org/scm/pt/oneposda.git
```

You can place this directory anywhere you like.

After it has finished downloading move into the directory and initialize your configuration, this will also download the docker containers.

```bash
cd oneposda
./init
```

## Configure Storage
The bulk of the storage will be from the "Posda Cache", where all imported
and edited DICOM files are stored. There is also the Postgres database data,
if you are using the built-in database.

By default both storage locations are managed by Docker, but you may want
to configure the location yourself, such as on network attached storage.

The main way you do this is by changing the `volume` sections within the
various services in the `docker-compose.yaml` file.

For example, if you wanted to place all of the cache (DICOM) files within
the host directory `/mnt/storage/posda`, you would find all lines within
`docker-compose.yaml` that look like:

```text    
- posda_cache_alpine:/home/posda/cache
```

and change them to:

```text    
- /mnt/storage/posda:/home/posda/cache
```

Make sure you change all occurrences!

NOTE: You should ensure that the owner:group ID of the chosen location
is `2123:2123`. 

If you additionally wanted to change where the built-in Postgres database
stores its data, first choose a location (such as `/mnt/storage/database`),
then change the line that looks like:

```text
- pgdata_alpine:/var/lib/postgresql/data
```

to instead be:

```text
- /mnt/storage/database:/var/lib/postgresql/data
```

## Configure Database
If you have chosen to use a separate database host (instead of using the
container), you will need to complete this section.

First, you must remove the `db` service from the `docker-compose.yaml` file.
Remove these lines:

```yaml
db:
	image: postgres:10.1-alpine
	restart: always
	environment:
		POSTGRES_PASSWORD: example
	volumes:
		- pgdata_alpine:/var/lib/postgresql/data
	ports:
		- 5433:5432
```

Then, find every occurrence of `depends_on: db` and remove it. For example,
remove only the `- db` line from the following:

```yaml
depends_on:
	- db
	- redis
```

Remove this everywhere it occurs, otherwise the various containers will fail
to start.

Finally, you must edit the `database.env` file, and set the appropriate values
for the database server you have configured. You must use a role which has
the ability to create databases. After initial configuration you can remove
that right, if you want.

Example:

```bash
PGHOST=my-database-host.uams.edu
PGUSER=posda
PGPASSWORD=s3cret!
```


## Configure Common Settings
Edit the file `common.env` and set the values. In particular, you should
carefully choose `POSDA_EXTERNAL_HOSTNAME`. 


## Start Posda
The first time you start Posda, you will want to start the `db` and `posda`
containers first, and wait about 30 seconds after each command for
initial setup to complete.

The `manage` script is a simple wrapper around `docker-compose`, but it
configures some things before each run, so it is recommend you use it
rather than using `docker-compose` directly.

WARNING: If you have chosen to have a separate database host, you must skip
the first command.

From the `oneposda` directory, execute:

```bash
./manage up -d db
# Wait 30 seconds for the database to start
./manage up -d posda
# Wait 30 seconds for initial setup to complete
./manage up -d
```
