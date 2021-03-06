# docker-ttrss

This docker image allows you to run the [Tiny Tiny RSS](http://tt-rss.org) feed reader.
Keep your feed history to yourself and access your RSS and atom feeds from everywhere.
You can access it through an easy to use webinterface on your desktop, your mobile browser
or using one of available apps.
This is a [docker](https://www.docker.io) image that eases setup.

## About Tiny Tiny RSS

> *From [the official readme](http://tt-rss.org/redmine/projects/tt-rss/wiki):*

Tiny Tiny RSS is an open source web-based news feed (RSS/Atom) reader and aggregator,
designed to allow you to read news from any location,
while feeling as close to a real desktop application as possible.

![](http://tt-rss.org/images/1.9/1.jpg)

## Quickstart

This section assumes you want to get started quickly, the following sections explain the
steps in more detail. So let's start.

Just start up a new database container:

```bash
$ docker run -d --name ttrssdb nornagon/postgres
```

And because this docker image is available as a [trusted build on the docker index](https://index.docker.io/u/clue/ttrss/),
using it is as simple as launching this Tiny Tiny RSS installation linked to your fresh database:

```bash
$ docker run -d --link ttrssdb:db -p 80:80 clue/ttrss
```

Running this command for the first time will download the image automatically.

## Accessing your webinterface

The above example exposes the Tiny Tiny RSS webinterface on port 80, so that you can browse to:

http://localhost/

The default login credentials are:

* Username: admin
* Password: password

Obviously, you're recommended to change these as soon as possible.

## Installation Walkthrough

Having trouble getting the above to run?
This is the detailed installation walkthrough.
If you've already followed the [quickstart](#quickstart) guide and everything works, you can skip this part.

### Running

Following docker's best practices, this container does not contain its own database,
but instead expects you to supply a running instance. 
While slightly more complicated at first, this gives your more freedom as to which
database instance and configuration you're relying on.
Also, this makes this container quite disposable, as it doesn't store any sensitive
information at all.

#### Starting a database instance

This container requires a PostgreSQL database instance. You're free to pick (or build)
any, as long as is exposes its database port (5432) to the outside.

Example:

```bash
$ sudo docker run -d --name=ttrssdb nornagon/postgres
```

#### Testing ttrss in foreground

For testing purposes it's recommended to initially start this container in foreground.
This is particular useful for your initial database setup, as errors get reported to
the console and further execution will halt.

```bash
$ sudo docker run -it --link ttrssdb:db -p 80:80 clue/ttrss
```

##### Database configuration

Whenever your run ttrss, it will check your database setup. It assumes the following
default configuration, which can be changed by passing the following additional arguments:

```
-e DB_NAME=ttrss
-e DB_USER=ttrss
-e DB_PASS=ttrss
```

##### Database superuser

When you run ttrss, it will check your database setup. If it can not connect using the above
configuration, it will automatically try to create a new database and user.

For this to work, it will need a superuser account that is permitted to create a new database
and user. It assumes the following default configuration, which can be changed by passing the
following additional arguments:

```
-e DB_ENV_USER=docker
-e DB_ENV_PASS=docker
```

#### Running with external database server

If you already have a PostgreSQL or MySQL server around off docker you also can go with
that.  Instead of linking docker containers you need to provide database hostname, port,
database name and user credentials manually like so:

```
-e DB_HOST=172.17.42.1
-e DB_PORT=3306
-e DB_NAME=ttrss
-e DB_USER=ttrssuser
-e DB_PASS=ttrsspass
```

If your database is exposed on a non-standard port you also need to provide DB_TYPE set
to either "pgsql" or "mysql".

#### Running with mysql database server

If you'd like to use ttrss with a mysql database backend, simply use the additional
database configuration arguments to docker mentioned above.

You also might want to link ttrss container to a mysql container.  If the mysql server
is exposed on port 3306 it will be detected automatically, otherwise you need to specify
DB_TYPE env flag.

```bash
$ sudo docker run -name mysql -d sameersbn/mysql:latest
$ sudo docker run -it --link mysql:db -p 80:80 clue/ttrss
```

#### Running ttrss daemonized

Once you've confirmed everything works in the foreground, you can start your container
in the background by replacing the `-it` argument with `-d` (daemonize).
Remaining arguments can be passed just like before, the following is the recommended
minimum:

```bash
$ sudo docker run -d --link tinystore:db -p 80:80 clue/ttrss
```
