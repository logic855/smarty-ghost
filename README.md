Smarty Ghost
============

Install [Ghost](https://ghost.org) on a Joyent SmartOS instance.


The `install-ghost.sh` pretty much does most of the heavy lifting for you, from downloading and unzipping [Ghost](https://ghost.org), installing it, configuring it, and keeping it running via an SMF service.


Configuration
-------------
Before you run the script, you should change `HOSTNAME` to the domain name you want to use and `ghostversion` to the version of [Ghost](https://ghost.org) you want (0.4.1 is the latest vailable as of this writting).

The config.js file for Ghost can be found in `/home/admin/ghost/.config.js` if you need to make any furter adjustments. Don't forget to restart Ghost  (see [Stopping, starting, and restarting Ghost](#stopping-starting-and-restarting-ghost))!

*NOTE*
The SMF service sets NODE_ENV so that Ghost is run in production mode. You may not want this if you are setting up Ghost for development. You can change this by removing the following from `install-ghost.sh`:

```
<envvar name="NODE_ENV" value="production"/>
```


Usage
-----

Run the `install-ghost.sh` script on a SmartOS instance (e.g. a "base 13.3.1") to download and install [Ghost](https://ghost.org). 

```
./install-ghost.sh
```

You can also downlod and run the script all in one command on your instance with:

```
curl -s https://raw.github.com/chorrell/smarty-ghost/master/install-ghost.sh | bash
```

Once that's compelete, you can makge any changes to the Ghost config.js file and restart the Ghost service (see [Stopping, starting, and restarting Ghost](#stopping-starting-and-restarting-ghost)).


Stopping, starting, and restarting Ghost
----------------------------------------

Once Ghost has been installed via the `install-ghost.sh` script, you can stop Ghost with:

```
svcadm disable ghost
```

You can restart Ghost again with"

```
svcadm enable ghost
```

Restart the Ghost service:

```
svcadm restart ghost
```

The last command is the most relevant and useful it you are installing new themes (they won't show up until you restart Ghost) or if you need to make a change to `/home/admin/ghost/.config.js`.

