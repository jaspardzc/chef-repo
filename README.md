About This Repository
=====================
The repository contains two sub directory, one directory contains chefscripts, one directory contain configration related json files.

Directory `chefscripts` contains all chef cookbooks, including both chef community cookbooks and development cookbooks.

All development cookbooks will start with prefix `dev_`

Directory `chefconfig` contains node, roles, environments, and data bags related json configuration files. 

In the actual DevOps Environment, it is recommended to have separate reposiotories for the `chefscripts` and `chefconfig` directory. And separating the community cookbooks from development cookbooks rather than keeping them all under one single MonoRepository.

For new chef node environment setup, checkout the last section of this README.

Chef References
===========
Official Website

    https://www.chef.io/chef/

Official Documentation

    https://docs.chef.io/

Community Chef Cookbooks

    https://github.com/chef-cookbooks

Commands Reference
==================
Frequently Used Handy Commands when using Chef

grep
----
Search for keywords in cookbooks

    ~$ grep -R -i "any keywords which is there in cookbook"

awk
---
To converting pem file into one line string, so that pem file can be stored as a data bag item 

    ~$ awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' certification.pem > certification.pem.temp
    ~$ rm certification.pem
    ~$ mv certification.pem.temp certification.pem
    ~$ rm certification.pem.temp

openssl
-------
To generate secret keys for data bag

    ~$ openssl rand -base64 512 | tr -d '\r\n' > /etc/chef/SECRET_KEY_NAME


knife
-----
Knife is a powerful tool for communication between chef server and chef nodes, managing environment, nodes, roles, data-bags, cookbooks, ssh, global search, and more 

Configuration

    ~$ knife configure -i
    ~$ knife ssl fetch
    ~$ knife ssl check
    ~$ knife client list
    ~$ knife 

Manage Cookbooks

    ~$ knife cookbook list
    ~$ knife cookbook upload COOKBOOK_NAME 
    ~$ knife cookbook delete COOKBOOK_NAME 
    ~$ knife cookbook download COOKBOOK_NAME

Manage Environments

    ~$ knife environment create ENV_NAME
    ~$ knife environment delete ENV_NAME
    ~$ knife environment edit ENV_NAME
    ~$ knife environment from file /path/ENV_NAME.json
    ~$ knife environment list -w
    ~$ knife environment show ENV_NAME -F json/text/yaml/pp
    ~$ knife environment compare ENV_NAME_1 ENV_NAME_2
    ~$ knife environment --all

Manage Nodes

    ~$ knife node list -w
    ~$ knife node show NODE_NAME -F json/text/yaml/pp
    ~$ knife node edit NODE_NAME
    ~$ knife node create NODE_NAME
    ~$ knife node environment_set NODE_NAME ENV_NAME
    ~$ knife node run_list add NODE_NAME 'recipe[COOKBOOK_NAME::RECIPE_NAME]'
    ~$ knife node run_list add NODE_NAME 'role[ROLE_NAME]'
    ~$ knife node run_list remove NODE_NAME 'recipe[COOKBOOK_NAME::RECIPE_NAME]'
    ~$ knife node run_list set NODE_NAME 'recipe[COOKBOOK_NAME::RECIPE_NAME], recipe[COOKBOOK_NAME::RECIPE_NAME]'
    ~$ knife node show build

Manage Roles

    ~$ knife role create ROLE_NAME
    ~$ knife role delete ROLE_NAME
    ~$ knife role edit ROLE_NAME
    ~$ knife role from file /path/NODE_NAME.json
    ~$ knife role list
    ~$ knife role show -F json/text/yaml/pp

Manage Databags

    ~$ knife data bag create BAG_NAME
    ~$ knife data bag delete BAG_NAME
    ~$ knife data bag create BAG_NAME BAG_ITEM_NAME
    ~$ knife data bag from file BAG_NAME BAG_ITEM_NAME
    ~$ knife data bag from file BAG_NAME BAG_ITEM_NAME --secret-file /path/KEY_NAME
    ~$ knife data bag show BAG_NAME BAG_ITEM_NAME --secret-file /path/KEY_NAME
    ~$ knife data bag delete BAG_NAME BAG_ITEM_NAME
    ~$ knife data bag create BAG_NAME
    ~$ knife data bag create BAG_NAME

SSH

Checking uptime for specific node based on the NODE_NAME

    ~$ knife ssh "name:DEV-NODE-001.example.com" "uptime" -x USER_NAME -p 22 -P PASSWD

Running chef client on specific node based on the NODE_NAME

    ~$ knife ssh "name:DEV-NODE-001.example.com" "sudo chef-client" -x USER_NAME -p 22 -P PASSWD

Running chef-client on multiple nodes based on shared common role

    ~$ knife ssh "role:common" "sudo chef-client" -x USER_NAME -p 22 -P PASSWD

Global Search

Searching the nodes based on node attributes

    ~$ knife search node "chef_environment:DEV AND platform:redhat"

Gem
---
Gem is used to install rubygems, since ruby is the default programming language for writing chef cookbooks, there are a lot of community cookbooks which have dependent rubygems.

Gem comes along with Chef Installation, to verify installation

    ~$ which gem
    or ~$ gem --version

Installing gems from cloud

    ~$ gem install 'gem_name'

Installing gems from local gem file

    ~$ gem install --local /path/**.gem

View all installed gems

    ~$ gem list

Check default gem remote repository uri

    ~$ gem sources

Add gem repo

    ~$ gem sources -a REPO_NAME

Chef-Server-CTL
---------------

To generate the pem files for authentication between chef client and chef server

    ~$ chef-server-ctl user-create admin admin admin USER@example.com 'admin123' --filename /etc/chef/admin.pem
    ~$ chef-server-ctl org-create example 'Example Inc' --association_user admin --filename /etc/chef/example-validator.pem

    chef-server-ctl user-create devadmin dev admin devadmin@example.com 'devadmin' --filename /etc/chef/devadmin.pem
    chef-server-ctl org-user-add example devadmin

show all the public keys for specific user

    ~$ sudo chef-server-ctl list-user-keys USER_NAME --verbose

list all organizations currenlt present on the chef server

    ~$ sudo chef-server-ctl org-list -a -w

show details of one organization

    ~$ chef-server-ctl org-show ORG_NAME

list all the users 

    ~$ sudo chef-server-ctl user-list

list all super users

    ~$ sudo chef-server-ctl list-server-admins

Chef-Client
-----------

- Configuration for New Chef Node

Register the chef node with chef server

    ~$ chef-client -S https://chefserver.healthtranzform.com/organizations/example -K /etc/chef/example-validator.pem

Generating chef node default attributes after a successful chef-client run

    ~$ chef-client

- Running on local mode

running with default recipe

    $ chef-client --local-mode --runlist='recipe[COOKBOOK_NAME]'

running with specific recipe

    $ chef-client --local-mode --runlist='recipe[COOKBOOK_NAME::RECIPE_NAME]'

- Running on the fly

running with all the cookbooks and recipes defined in the default runlist

    $ chef-client

running with specific runlist

    $ chef-client --runlist='recipe[COOKBOOK_NAME::RECIPE_NAME], recipe[COOKBOOK_NAME::RECIPE_NAME]'

Chef-Apply
----------

Running recipe or single ruby file without cookbooks

    ~$ chef-apply /path/FILE_NAME.rb

Chef Environment Manually Setup (For Linux Kernel 4.x+)
=======================================================

This section is a sample guideline for manually chef environment setup,especially useful for 

Chef Server
-----------
Chef Development Workstation (ChefDK)
-----------
Chef Client(Chef Node)
-----------


Chef Basics
===============

The chef-repo
-------------
All installations require a central workspace known as the chef-repo. This is a place where primitive objects--cookbooks, roles, environments, data bags, and chef-repo configuration files--are stored and managed.

The chef-repo should be kept under version control, such as [git](http://git-scm.org), and then managed as if it were source code.

Knife Configuration
-------------------
Knife is the [command line interface](https://docs.chef.io/knife.html) for Chef. The chef-repo contains a .chef directory (which is a hidden directory by default) in which the Knife configuration file (knife.rb) is located. This file contains configuration settings for the chef-repo.

The knife.rb file is automatically created by the starter kit. This file can be customized to support configuration settings used by [cloud provider options](https://docs.chef.io/plugin_knife.html) and custom [knife plugins](https://docs.chef.io/plugin_knife_custom.html).

Also located inside the .chef directory are .pem files, which contain private keys used to authenticate requests made to the Chef server. The USERNAME.pem file contains a private key unique to the user (and should never be shared with anyone). The ORGANIZATION-validator.pem file contains a private key that is global to the entire organization (and is used by all nodes and workstations that send requests to the Chef server).

Cookbooks
---------
A cookbook is the fundamental unit of configuration and policy distribution. 

Roles
-----
Roles provide logical grouping of cookbooks and other roles. 

