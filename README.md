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

Sample Moodle configuration
-----

Settings > Site administration > Plugins > Authentication > Manage authentication -> enable self-registration below the table

Settings > Site administration > Plugins > Manage message outputs -> email -> settings -> SMTP hosts: smtp.gmail.com:465 , SMTP security: SSL, SMTP username: Your email address @gmail.com

Settings > Site administration > Server > Support contact -> Support name and support email

http://docs.moodle.org/22/en/File_upload_size#Ubuntu_Linux_Instructions
Settings > Site administration > Security -> Site policies -> Maximum uploaded file size

Site Administration>Appearance>Additional HTML
and follow the instruction: http://pdtechu.sqooltechs.com/mod/page/view.php?id=4474
so you can get an automatic translation and edit it (like the one of 'There are no upcoming events') providing that you have logged in your gmail on the same browser. The site owner can go to the top bar and manage the translation of the whole content, correct, approve translations and invite editors.

Settings > Site administration > language -> language packs -> install
Users can choose the official language of the software from their profile page.
Settings > Site administration > Plugins > Filters->Manage Filters: 
Multi-Language Content: enable this filter (disabled by default)

Settings > Site administration > Plugins > Manage repositories -> At Dropbox select "enable and visible" -> click on the link to dropbox -> create a Dropbox API, not a Dropin => copy key and secret to the moodle page

Sample Course configuration
-----

course administration -> edit settings -> enable guest
course administration -> edit settings -> appearance -> activity reports
course administration -> edit settings -> completion tracking

course format -> topic
when adding an activity or a resource, 1) set the criteria for Activity completion and 2) restrict access by allowing access from specific date
social forum -> subscription= auto, read tracking=on

Export books as IMS but import chapters.

(backup does not back up wiki pages. Slideshow does not work. Subchapters cannot be imported as sub-chapters. Moodle supports flv video format.)

How to package the virtual machine
-----

As moodle cannot be configured from command line, you can distribute your modified virtual machine with the following commands:

git clone https://github.com/nickmeet/moodle-box.git

cd moodle-box

vagrant up

and once you finish configuring localhost:8081

vagrant package --vagrantfile Vagrantfile

How to deploy a virtual machine
-----

You should get the files localbox.zip and package.box and install virtualbox and vagrant (if you have Vagrant 1.3.5, use VirtualBox 4.2.18 as there is a known issue with 4.3). Extract the localbox.zip on a folder, put there also the file package.box and type the following commands

vagrant box add my_box /path/to/the/package.box

vagrant up

Below you can find the username/password that you will need:

virtual machine account: vagrant/vagrant

admin: admin/adminpass

student: nikos/Nikos85!

Other info
-----

To install a moodle module, download it, put it at /usr/local/moodle/mod/ and go to site administration -> notifications -> upgrade
sudo sed -i '/iamac71.epfl.ch:8080/ s/iamac71.epfl.ch:8080/128.178.146.104:8081/' /usr/local/moodle/mod/widgetspace/lib/container.php

