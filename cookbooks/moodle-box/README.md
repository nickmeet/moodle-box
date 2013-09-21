Moodle box : Vagrant take=away
==============================

A Vagrantfile, a cookbook. Working hands in hands.

Install
-------

Install [VirtualBox](https://www.virtualbox.org/) and
[Vagrant](http://www.vagrantup.com/).

Install the vagrant berkshelf plugin: `vagrant plugin install berkshelf-vagrant`

Finally run `vagrant up` to start and provision the VM.

After the box is finished provisioning, Moodle is available on an
internal host at http://172.22.83.237

Login: admin / adminpass

Usage
-----

For development, make sure to enable the debugging in site Settings ->
Developer
