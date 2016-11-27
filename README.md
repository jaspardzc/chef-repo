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
1. download chef server rpm image, check Linux/Unix version on the chef official website
2. login as root
3. adding the ip address mapping in the /etc/hosts for the chef server
    ```
    xx.xx.xx.xx chefserver.companyname.projectname.com
    ```
4. install openssl, download the tar and ftp it to the chef server VM
5. add group and user 
    ```
    ~$ groupadd -g 751 opscode
    ~$ useradd -m -d /home/opscode -u 751 -g 751 -p opscode opscode
    ~$ useradd -m -d /home/opscode-pgsql -u 752 -g 751 -p opscode opscode-pgsql
    ```
6. install chef server
    ```
    ~$ rpm -Uvh chef.xxxxx.rpm
    ~$ chef-server-ctl reconfigure
    ```
7. generate PEM files for authentication with chef client
    ```
    ~$ chef-server-ctl user-create admin admin admin admin@trizetto.com 'admin123' --filename admin.pem
    ~$ chef-server-ctl org-create trizetto 'TriZetto Inc' --association_user admin --filename trizetto-validator.pem
    ~$ chef-server-ctl user-create devadmin dev admin devadmin@trizetto.com 'devadmin' --filename /etc/chef/devadmin.pem
    ~$ chef-server-ctl org-user-add trizetto devadmin
    ```
8. install the chef manage
    ```
    # download chef-managexxx.rpm
    ~$ rpm -Uvh chef-managexxx.rpm
    ~$ chef-manage-ctl reconfigure
    # install chef manage using chef-server-ctl
    ~$ chef-server-ctl install chef-manage /opt/chef-manage/LICENSES/libffi-LICENSE
    ```
Chef Development Workstation (ChefDK)
-------------------------------------
1. install the ChefkDK rpm image, check Linux/Unix version on chef official website (ChefDK will automatically have knife, chef-client, kitchen, berkshelf installed)
2. add ruby and gem to the system path
    ```
    ~$ export PATH=$PATH:/opt/chefdk/embedded/bin
    ~$ which ruby
    ~$ which gem
    ```
3. same as Chef Client configuration, see below
Chef Client(Chef Node)
----------------------
1. install the Chef.xxx.rpm, check Linux/Unix version on the chef official website, login the chefserver admin UI, create a client and download new client pem key, put at `/root/.chef/client.pem`
2. add ruby and gem to the system path
    ```
    ~$ export PATH=$PATH:/opt/chefdk/embedded/bin
    ~$ which ruby
    ~$ which gem
    ```
3. create knife.rb at /root/.chef/
    ```
    ~$ sudo su -
    ~$ mkdir /root/.chef/
    ~$ vi /root/.chef/knife.rb (optionally, ~$ knife configure -i)
    ~$ exit
    ```
    /root/.chef/knife.rb reference
    ```
    log_level                   :info
    log_location                STDOUT
    node_name                   'admin'
    client_key                  '/root/.chef/admin.pem'
    validation_client_name      'example-validator'
    validation_key              '/root/.chef/example-validator.pem'
    chef_server_url             'https://chefserver.example.com:443/organizations.example'
    syntax_check_cache_path     '/root/.chef/syntax_check_cache'
    ```
4. create knife.rb at ~/.chef/
    ```
    ~$ sudo su - devadmin
    ~$ mkdir ~/.chef/
    ~$ vi /root/.chef/knife.rb (optionally, ~$ knife configure -i)
    ~$ exit
    ```
    ~/.chef/knife.rb reference
    ```
    current_dir = File.dirname(__FILE__)
    log_level                   :info
    log_location                STDOUT
    node_name                   'devadmin'
    client_key                  "#{current_dir}/.chef/devadmin.pem"
    chef_server_url             'https://chefserver.example.com:443/organizations.example'
    cookbook_path               ["#{current_dir}/../chef-repo/chefscripts/cookbooks"]
    ```
5. create knife.rb at /etc/chef/
    ```
    ~$ vi /etc/chef/client.rb
    ```
    /etc/chef/client.rb reference
    ```
    log_level                   :info
    log_location                STDOUT
    node_name                   'admin'
    validation_client_name      'example-validator'
    validation_key              '/etc/chef/example-validator.pem'
    chef_server_url             'https://chefserver.example.com:443/organizations.example'
    trusted_certs_dir           '/root/.chef/trusted_certs'
    ```
6. added the chef server IP address into /etc/hosts 
    ```
    # chef server
    xx.xx.xx.xx chefserver.example.com
    ```
7. puts admin.pem and example-validator.pem inside /root/.chef/ and /etc/chef/
8. download certification from chef server, which will be put under /root/.chef/trusted_certs/
    ```
    ~$ knife ssl fetch
    ~$ knife ssl check
    ```
9. register the chef node with chef server
    ```
    ~$ chef-client -S https://chefserver.example.com/organizations/example -K /etc/chef/example-validator.pem
    ```
10. verify the chef-client configuration setup
    ```
    ~$ knife client-list -w
    ```

Chef Design Pattern Best Practice
=================================

Top 1 Question: The Berkshelf Way or Role-based Way? Followed are some links for reference, you can google more debates on this.

[Write Reusable Chef Cookbooks, No Roles](http://devopsanywhere.blogspot.com/2012/11/how-to-write-reusable-chef-cookbooks.html)

[Chef Roles are not Evil](https://blog.chef.io/2013/11/19/chef-roles-arent-evil/)

[Chef Cookbooks Anti Patterns](http://dougireton.com/blog/2013/02/16/chef-cookbook-anti-patterns/)

In the chef world, some people advocates against setting attributes and runlist in roles, or even not using roles at all. The main concerns of these people are:

    Roles are not versioned and shared across all the nodes and environments
    Roles cannot be namespaced
    Roles cannot be packages and distributed
    Roles added additional setup complexity for the user

The Chef Official Documentation says:

    A role is a way to define certain patterns and processes that exist across nodes in an organization as belonging to a single job function. Each role consists of zero (or more) attributes and a run list.

It is very much like the Spring AOP, dealing with cross-cutting concern, providing reusable components that can be easily maintained and embedded for any environement and node usage. 

Roles will be evaludated during the chef-client run, the roles atrributes will be merged into the node and environment based on attribute precedence, the roles runlist will be embedded in the node runlist if you have include the roles in your node runlist. 

But, we should be cautious when using roles within different environments, roles are not suitable for every scenarios. Whenever you modify a recipe in the role runlist or modify a attribute in the role, it will be immediately reflected on all the nodes that are using this shared role.

Generally, there are two ways to use roles.

The Classical Way
-------------------
1. Use Roles for every entities like webservers, databases, services, etc. If we want the role to behave differently in different environments, we need to set some environment override attributes to override the default attribute value declared in the role.

2. If we want the role to behave differently in different nodes, we need to set some force_override attributes to override the default attribute value declared in the role.

But this approach will definitely resulted in repeatly adding a lot of force override attribute all over the places if your application stack is very complex. (Countless Environments and Nodes)

Maybe a Better Way (Role-based Cookbook)
----------------------------------------

Make use of the power of cookbooks, because cookbooks can be versioned.
There are three types of cookbooks.

```
Library Cookbook/Community Cookbook
Application Cookbook
Role/Wrapper Cookbook
```

And we are going to use the role/wrapper cookbook to achieve this:

1. Create a wrapper cookbook for each entity role, add the default recipe of this wrapper cookbook inside the entity role.

    for the role runlist

    ```
    "run_list": [
      "role[webserver]",
      "recipe[webserver]"
    ]
    ```

2. Using include_recipe to include multiple recipes in the default recipe of this wrapper cookbook.

    for the default.rb of wrapper cookbook webserver
    
    ```
    include_recipe "cts_git_cb::syn_chef_repo"
    include_recipe "cts_git_cb::sync_ms_config"
    include_recipe "cts_git_cb::upload_chefscripts"
    .....
    include_recipe "cts_tomcat_cb::stop_container"
    ....
    ```

3. When you want the roles to behave differently in different environments and node, simply distributing another version of this wrapper cookbook.

    for the role runlist in QA Environment
    
    ```
    "run_list": [
      "role[webserver]",
      "recipe[webserver@2.0.0]"
    ]
    ```

    for the role runlist in PROD Environment
    
    ```
    "run_list": [
      "role[webserver]",
      "recipe[webserver@1.5.0]"
    ]
    ```

4. Happily use roles, no need to pollute the node attributes and messy around the node default runlist


Open Topics
===========

