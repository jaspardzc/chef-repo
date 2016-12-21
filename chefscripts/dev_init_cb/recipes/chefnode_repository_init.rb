####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: chefnode_repository_init
# Resources: synchronize local chef repo with remote chef repo hosted under Git SCM
#
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# read git secret key path
secret_key_path = node['git']['secret_key_path']

# read git credential from encrypted data bag item
git_credential = data_bag_item("git_bag", "credential", IO.read(secret_key_path))

# create env_configuration directory
execute 'create env_configuration directory' do
    user 'devadmin'
    group 'devadmin'
    command "mkdir -p /dev/chef/env_configuration"
    only_if { !File.directory?("/dev/chef/env_configuration") }
    action :run 
end

# synchronize env_configuration
git 'synchronize env_configuration' do
    destination "/dev/chef/env_configuration"
    repository "http://#{git_credential['username']}:#{git_credential['password']}@#{node['git']['base_git_url']}/env_configuration_#{node.chef_environment}"
    revision 'master'
    action :sync
    user 'devadmin'
    group 'devadmin'
end