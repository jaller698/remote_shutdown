# Intro
This is a small basic program which aims to be a smart way to remotely shutdown your computer, or get it to restart.

It supports the following commands:
- hibernate
- logout
- reboot
- shutdown
- sleep

It is confirmed to work on Linux and Windows, and should also work on MacOS. 

# Installation
git clone this repo, then run the command cargo build or download the right binaries into the cloned folder.

Insert the correct settings in the `config.ini`, adjust the key to your liking and set the port. 

Afterwards as either sudo or administrator run the `set_as_service` script. Which will either use NSSM or systemd to install the service and set it to automatic startup. 

# How to use
When the service is up and running, can be confimed by running `nmap -p $PORT_NUMBER localhost`. 

You can send a shutdown command like: `curl 127.0.0.1:$PORT_NUMBER/$KEY/shutdown` in the default case it would be `curl 127.0.0.1:5001/secret/shutdown`

To send another command, just replace shutdown with any of the other commands.