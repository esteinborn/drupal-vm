#Getting Vagrant/Virtual Box/Drupal-VM working on a Windows box connected to Acquia
This is a step-by-step for what worked for me.

Prerequisites
============
- Install Vagrant 1.7.4 (should work w/ vagrant-1.8.1 too)
- Install VirtualBox (latest version) **
- Git Clone https://github.com/justinlevi/drupal-vm

** Potential issue w/ Intel Ix Core situation.  You need to turn on virtualization in the BIOS


INSTRUCTIONS
============

* Download the above prerequisites. 
* unzip & copy/replace the C_Hashicorp/Vagrant/embedded/gems/gems/vagrant-1.xx/plugins/provisioners/ansible.zip with the ansible folder at the same path on your host computer

Make sure your .ssh keys are setup and in the right place
- https://help.github.com/articles/generating-an-ssh-key/
-  Duplicate all .ssh files that live somewhere else into your c:/Users/YOUR-USERNAME/.ssh folder


### Forward `ssh-agent` TO Virtual Machine
Windows - The ssh-agent does not run by default and/or does not startup even after you run these commands.
Solution: Run these commands each time, or add them to your .bash_profile or a shell script of some sort.
This is a miserable problem and is documented here: http://stackoverflow.com/questions/17846529/could-not-open-a-connection-to-your-authentication-agent
Below are three solutions that worked for me. YMMV

### \#3 below is my personal fav because it fires when I open Cmder

- 1. Run this from git bash
eval `ssh-agent -s`
ssh-add

or

- 2. "C:\Program Files (x86)\Git\cmd\start-ssh-agent.cmd"
from the Command Prompt

or

If you're using Cmder, do this:
- 3. https://github.com/cmderdev/cmder/issues/193#issuecomment-63041617


# Setup the Virtual Machine instance
- cd into this repository directory
- run `vagrant up`


===================

## Download your Acquia Drush aliases
https://docs.acquia.com/cloud/drush-aliases

Extract them to your $HOME Directory
- run this at your command prompt to find this location : echo %USERPROFILE%
- Also, copy both .acquia & .drush folders into your site root

Check to see if the following alias was created in your $HOME/.drush folder
drupalvm.aliases.drushrc.php

If not, then create it and add the following

```
$aliases['drupalvm.dev'] = array(
  'uri' => 'drupalvm.dev',
  'root' => '/var/www/drupalvm',
  'remote-host' => 'drupalvm.dev',
  'remote-user' => 'vagrant',
  'ssh-options' => '-o PasswordAuthentication=no -i ~/.vagrant.d/insecure_private_key',
);
```

## Connect to the database

Create the following directory for you drupalvm settings.php file
`sites/all/drupalvm.dev/settings.php`

```
 <?php
  $databases['default']['default'] = array(
    'driver' => 'mysql',
    'database' => 'drupal',
    'username' => 'drupal',
    'password' => 'drupal',
    'host' => 'localhost',
   'prefix' => '',
  );

  $conf['securepages_enable'] = FALSE;
  $conf['file_private_path'] = '/var/www/drupalvm/drupal-private-file-system';
  $conf['file_temporary_path'] = '/var/www/drupalvm/drupal-temporary-path';
  ```

## Download the database to your local virtual machine
$ `drush @nysptracs.dev sql-dump | drush @drupalvm.drupalvm.dev sql-cli`

#Install the Drush registry_rebuild "module"
Note: For Drupal 7 I needed to make sure I had the `drush registry_rebuild` available and it doesn't ship with drush 8. You can install it via:

$ `drush @drupalvm.drupalvm.dev dl registry_rebuild`

clear your drush cache
$ `drush @drupalvm.drupalvm.dev cc drush`

Next I had to manually truncate all database tables

##### This should work, but it doesn't - Currently just lists out the truncate SQL that would need to run.
  ```
  drush @drupalvm.drupalvm.dev sql-query "SELECT DISTINCT concat(\"TRUNCATE TABLE \", TABLE_NAME, \";\") FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE \"cache%\";"
  ```

## Alternatively - login to the http://adminer.drupalvm.dev and select all of the cache tables, and truncate them.
// TODO: figure out how to automate this.
u: drupal
p: drupal
db: drupal


Finally you need to rebuild the registry via

`drush @drupalvm.drupalvm.dev rr --fire-bazooka`


# Visit your new fancy site @ 
http://drupalvm.dev

# Heavily Rejoic :tada:


Drupal-VM Original Readme below
=======================================


![Drupal VM Logo](https://raw.githubusercontent.com/geerlingguy/drupal-vm/master/docs/images/drupal-vm-logo.png)

[![Build Status](https://travis-ci.org/geerlingguy/drupal-vm.svg?branch=master)](https://travis-ci.org/geerlingguy/drupal-vm) [![Documentation Status](https://readthedocs.org/projects/drupal-vm/badge/?version=latest)](http://docs.drupalvm.com)

[Drupal VM](http://www.drupalvm.com/) is A VM for local Drupal development, built with Vagrant + Ansible.

This project aims to make spinning up a simple local Drupal test/development environment incredibly quick and easy, and to introduce new developers to the wonderful world of Drupal development on local virtual machines (instead of crufty old MAMP/WAMP-based development).

It will install the following on an Ubuntu 14.04 (by default) linux VM:

  - Apache 2.4.x (or Nginx 1.x)
  - PHP 5.6.x (configurable)
  - MySQL 5.5.x
  - Drush (configurable)
  - Drupal Console (if using Drupal 8+)
  - Drupal 6.x, 7.x, or 8.x.x (configurable)
  - Optional:
    - Varnish 4.x (configurable)
    - Apache Solr 4.10.x (configurable)
    - Node.js 0.12 (configurable)
    - Selenium, for testing your sites via Behat
    - Ruby
    - Memcached
    - XHProf, for profiling your code
    - XDebug, for debugging your code
    - Adminer, for accessing databases directly
    - Pimp my Log, for easy viewing of log files
    - MailHog, for catching and debugging email

It should take 5-10 minutes to build or rebuild the VM from scratch on a decent broadband connection.

Please read through the rest of this README and the [Drupal VM documentation](http://docs.drupalvm.com/) for help getting Drupal VM configured and integrated with your development workflow.

## Documentation

Full Drupal VM documentation is available at http://docs.drupalvm.com/

## Customizing the VM

There are a couple places where you can customize the VM for your needs:

  - `config.yml`: Contains variables like the VM domain name and IP address, PHP and MySQL configuration, etc.
  - `drupal.make.yml`: Contains configuration for the Drupal core version, modules, and patches that will be downloaded on Drupal's initial installation (more about [Drush make files](https://www.drupal.org/node/1432374)).

If you want to switch from Drupal 8 (default) to Drupal 7 or 6 on the initial install, do the following:

  1. Update the Drupal `version` and `core` inside the `drupal.make.yml` file.
  2. Update `drupal_major_version` inside `config.yml`.

## Quick Start Guide

This Quick Start Guide will help you quickly build a Drupal 8 site on the Drupal VM using the included example Drush make file. You can also use the Drupal VM with a [Local Drupal codebase](http://docs.drupalvm.com/en/latest/deployment/local-codebase/) or even a [Drupal multisite installation](http://docs.drupalvm.com/en/latest/deployment/multisite/).

### 1 - Install dependencies (VirtualBox and Vagrant)

  1. Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (Drupal VM also works with Parallels or VMware, if you have the [Vagrant VMware integration plugin](http://www.vagrantup.com/vmware)).
  2. Download and install [Vagrant](http://www.vagrantup.com/downloads.html).

Note for Faster Provisioning (Mac/Linux only): *[Install Ansible](http://docs.ansible.com/intro_installation.html) on your host machine, so Drupal VM can run the provisioning steps locally instead of inside the VM.*

Note for Linux users: *If NFS is not already installed on your host, you will need to install it to use the default NFS synced folder configuration. See guides for [Debian/Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-14-04), [Arch](https://wiki.archlinux.org/index.php/NFS#Installation), and [RHEL/CentOS](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-centos-6).*

Note on versions: *Please make sure you're running the latest stable version of Vagrant, VirtualBox, and Ansible, as the current version of Drupal VM is tested with the latest releases. As of August 2015: Vagrant 1.7.4, VirtualBox 5.0.2, and Ansible 1.9.2.*

### 2 - Build the Virtual Machine

  1. Download this project and put it wherever you want.
  2. Make copies of both of the `example.*` files, and modify to your liking:
    - Copy `example.drupal.make.yml` to `drupal.make.yml`.
    - Copy `example.config.yml` to `config.yml`.
  3. Create a local directory where Drupal will be installed and configure the path to that directory in `config.yml` (`local_path`, inside `vagrant_synced_folders`).
  4. Open Terminal, cd to this directory (containing the `Vagrantfile` and this README file).
  5. (If you have Ansible installed on Mac/Linux) Run `$ sudo ansible-galaxy install -r provisioning/requirements.yml --force`.
  6. Type in `vagrant up`, and let Vagrant do its magic.

Note: *If there are any errors during the course of running `vagrant up`, and it drops you back to your command prompt, just run `vagrant provision` to continue building the VM from where you left off. If there are still errors after doing this a few times, post an issue to this project's issue queue on GitHub with the error.*

### 3 - Configure your host machine to access the VM.

  1. [Edit your hosts file](http://www.rackspace.com/knowledge_center/article/how-do-i-modify-my-hosts-file), adding the line `192.168.88.88  drupalvm.dev` so you can connect to the VM.
    - You can have Vagrant automatically configure your hosts file if you install the `hostsupdater` plugin (`vagrant plugin install vagrant-hostsupdater`). All hosts defined in `apache_vhosts` or `nginx_hosts` will be automatically managed.
    - You can also have Vagrant automatically assign an available IP address to your VM if you install the `auto_network` plugin (`vagrant plugin install vagrant-auto_network`), and set `vagrant_ip` to `0.0.0.0` inside `config.yml`.
  2. Open your browser and access [http://drupalvm.dev/](http://drupalvm.dev/). The default login for the admin account is `admin` for both the username and password.

## Extra software/utilities

By default, this VM includes the extras listed in the `config.yml` option `installed_extras`:

    installed_extras:
      - adminer
      - mailhog
      - memcached
      - pimpmylog
      # - solr
      # - selenium
      - varnish
      - xdebug
      - xhprof

If you don't want or need one or more of these extras, just delete them or comment them from the list. This is helpful if you want to reduce PHP memory usage or otherwise conserve system resources.

## Using Drupal VM

Drupal VM is built to integrate with every developer's workflow. Many guides for using Drupal VM for common development tasks are available on the [Drupal VM documentation site](http://docs.drupalvm.com):

  - [Syncing Folders](http://docs.drupalvm.com/en/latest/extras/syncing-folders/)
  - [Connect to the MySQL Database](http://docs.drupalvm.com/en/latest/extras/mysql/)
  - [Use Apache Solr for Search](http://docs.drupalvm.com/en/latest/extras/solr/)
  - [Use Drush with Drupal VM](http://docs.drupalvm.com/en/latest/extras/drush/)
  - [Use Drupal Console with Drupal VM](http://docs.drupalvm.com/en/latest/extras/drupal-console/)
  - [Use Varnish with Drupal VM](http://docs.drupalvm.com/en/latest/extras/varnish/)
  - [Use MariaDB instead of MySQL](http://docs.drupalvm.com/en/latest/extras/mariadb/)
  - [View Logs with Pimp my Log](http://docs.drupalvm.com/en/latest/extras/pimpmylog/)
  - [Profile Code with XHProf](http://docs.drupalvm.com/en/latest/extras/xhprof/)
  - [Debug Code with XDebug](http://docs.drupalvm.com/en/latest/extras/xdebug/)
  - [Catch Emails with MailHog](http://docs.drupalvm.com/en/latest/extras/mailhog/)
  - [Test with Behat and Selenium](http://docs.drupalvm.com/en/latest/extras/behat/)
  - [PHP 7 on Drupal VM](http://docs.drupalvm.com/en/latest/other/php-7/)
  - [Drupal 6 Notes](http://docs.drupalvm.com/en/latest/other/drupal-6/)

## Other Notes

  - To shut down the virtual machine, enter `vagrant halt` in the Terminal in the same folder that has the `Vagrantfile`. To destroy it completely (if you want to save a little disk space, or want to rebuild it from scratch with `vagrant up` again), type in `vagrant destroy`.
  - When you rebuild the VM (e.g. `vagrant destroy` and then another `vagrant up`), make sure you clear out the contents of the `drupal` folder on your host machine, or Drupal will return some errors when the VM is rebuilt (it won't reinstall Drupal cleanly).
  - You can change the installed version of Drupal or drush, or any other configuration options, by editing the variables within `config.yml`.
  - Find out more about local development with Vagrant + VirtualBox + Ansible in this presentation: [Local Development Environments - Vagrant, VirtualBox and Ansible](http://www.slideshare.net/geerlingguy/local-development-on-virtual-machines-vagrant-virtualbox-and-ansible).
  - Learn about how Ansible can accelerate your ability to innovate and manage your infrastructure by reading [Ansible for DevOps](http://www.ansiblefordevops.com/).

## License

This project is licensed under the MIT open source license.

## About the Author

[Jeff Geerling](http://jeffgeerling.com/), owner of [Midwestern Mac, LLC](http://www.midwesternmac.com/), created this project in 2014 so he could accelerate his Drupal core and contrib development workflow. This project, and others like it, are also featured as examples in Jeff's book, [Ansible for DevOps](http://www.ansiblefordevops.com/).
