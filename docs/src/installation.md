This is the installation guide for Posda.

## Prerequisites
The smallest installation requires one server, which can be running Linux,
Windows or MacOS, as long as it meets these minimum hardware and software
requirements.

__Note__: Most installs will be much larger than these minimum requirements,
and thus will require vastly more resources. The exact requirements will
depend on your configuration. See the 
[Type of Installation](#type-of-installation) section for more information.

### Hardware requirements

* Servers: 1 Linux, MacOS or Windows
* vCPUs: 4
* Memory: 8 GiB
* Storage: 10 TiB

### Software requirements

* [Docker](#install-docker) (and docker-compose)
* git

## Things to consider
There are a handful of things you should consider before beginning
installation, such as:

* What host OS will you use?
* What type of installation?
* Will storage be separate?
	* This allows for shared storage, which is necessary if Posda will
	be used alongside NBIA, for example.

* Will database be separate?

### Host OS
Posda is distributed as a set of [Docker](https://www.docker.com) containers,
which means that it will technically work on any platform Docker supports
(including Windows, MacOS, and Linux). However, we _highly_ recommend Linux be 
used for the best compatibility. 

Any Linux distribution should work, as long as you can install Docker, though
we have tested Posda on the following:

* Ubuntu 16.04, 18.04, 20.04
* RHEL 7
* CentOS 7

### Type of Installation
Posda supports a number of different installation configurations. The main
options are if separate storage will be used, and/or a separate database
server, and/or separate compute nodes (worker nodes).  The reasons why you
would make these choices are beyond the scope of this documentation, but you
should make those choices before beginning installation.

We have included three example configurations in this guide:

* Small - All-in-one server (for a small site, or development, or demonstration)
* Medium - Single server, separate storage
* Large - Multiple servers; separate storage, database, and worker nodes


## Install Sizes / Types
Here are three common types of installation, along with a list of which
sections you would need to complete for each.

### Small / Development Installation
This is the appropriate set of sections you would complete to install Posda
on a single machine, such as for development or demonstration purposes,
or a very small site. This option runs all services as Docker containers,
and allows Docker to manage all storage.

* [Clone the Repo](#clone-oneposda)
* [Configure Common Settings](#configure-common-settings)
* [Start Posda](#start-posda)


### Medium / Separate Storage
This example configuration is for an installation where the main storage
is not managed by Docker. This would allow you to, for example, use an
existing network attached storage (NAS) device to house all image data. This
configuration uses only one server for all components.

* [Clone the Repo](#clone-oneposda)
* Connect storage to Host
* [Configure storage](#configure-storage) in docker-compose.yaml
* [Configure Common Settings](#configure-common-settings)
* [Start Posda](#start-posda)

### Large / Separate Storage, Separate Database, Separate Compute
This example configuration represents a large installation with separate
servers for the database and compute, as well as shared storage. This
option provides the most power and flexibility, while requiring the most
resources.

__Note__: some steps are beyond the scope of this document.

* Provision database server, install PostgreSQL
* Provision the main host and all desired worker node hosts, and follow these
  steps on each one:
	* [Clone the Repo](#clone-oneposda)
	* Connect storage to Host
	* [Configure storage](#configure-storage) in docker-compose.yaml
	* [Configure database](#configure-database)
	* [Configure Common Settings](#configure-common-settings)
	* [Configure Worker Nodes](#configure-worker-nodes)
	* [Start Posda](#start-posda)

_Warning_: Ensure the settings are consistent across all hosts!


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
is `1000:2123`. This is the UID and GID which Posda runs as inside the
containers, and setting it this way will guarantee Posda can write to
its storage directory. This is not a hard requirement, so long as the 
location is __writable__ by UID 1000.

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
carefully choose `POSDA_EXTERNAL_HOSTNAME`; it should be the hostname
where users will expect to find the Posda server.

## Configure Worker Nodes
By default, the docker-compose.yaml defines two Worker Nodes:

* High (priority 1)
* Low (priority 0)

By default, these will run on the same server as the rest of Posda.
You have a number of options for customizing this setup. You can define
additional priority levels (numeric), which you can use for more fine-grained
association of tasks with nodes (via further configuration that is beyond
the scope of this document). You can also choose to run additional nodes,
so that additional tasks can execute simultaneously. You can also choose
to run these nodes on dedicated systems to greatly expand the available
computing resources the Posda system has access to.

You can increase (or decrease) the number of running nodes of each type
by adjusting the `replicas` entry in the docker-compose.yaml file for each
type of worker node. By default the low (default) priority has 3 replicas,
and the high priority has 1. 

If you wish to run worker nodes on dedicated servers, you will need to be
running separate storage and database servers as well. You will need to
copy the `oneposda` repository (including the configuration files) to each
host that will run a worker node instance, then modify the docker-compose.yaml
(on those hosts only!) to remove all `service`s other than the desired
worker node entry. You should then be able to start it using `./manange up -d`
just like normal.


## Start Posda
The first time you start Posda, you will want to start the `db` and `posda`
containers first, and wait about 30 seconds after each command for
initial setup to complete.

The `manage` script is a simple wrapper around `docker-compose`, but it
configures some things before each run, so it is recommend you use it
rather than using `docker-compose` directly.

__Warning__: If you have chosen to have a separate database host, you must skip
the first command (because there will be no `db` container).

From the `oneposda` directory, execute:

```bash
./manage up -d db
# Wait 30 seconds for the database to start
./manage up -d posda
# Wait 30 seconds for initial setup to complete
./manage up -d
```
