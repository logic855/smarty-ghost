smarty-ghost
============

Install ghost on a Joyent SmartOS instance.

Usage
-----
Run the `install-ghost.sh` script on a SmartOS instance (e.g. base 13.3.1) to download and install Ghost. The script pretty much does most of the heavy lifting for you, from downloading and unzipping ghost, installing it, configuring it to run, and running it via and SMF service.

Configuration
-------------
Before you run it, you might want to change `HOSTNAME` to the domain name you want to use and `ghostversion` to the version og Ghost you want (0.4.1 is the latest vailable as of this writting).
