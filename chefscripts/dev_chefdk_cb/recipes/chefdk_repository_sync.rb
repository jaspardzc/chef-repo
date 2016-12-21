####################################################################################
# Cookbook Name: dev_chefdk_cb
# Recipe:: chefdk_repository_sync
# Resources: create local git repository - chefconfig
#            create local git repository - chefscripts
#            synchronize chefconfig
#            synchronize chefscripts
#            upload latest cookbooks to chefserver
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/21/2016
# Author: kevin.zeng
#####################################################################################

# read git secret key path
secret_key_path = node['git']['secret_key_path']

# read git credential from encrypted data bag item
git_credential = data_bag_item("git_bag", "credential", IO.read(secret_key_path))

# create local git repository - chefconfig
execute 'create local git repository - chefconfig' do
    user 'devadmin'
    group 'devadmin'
    command "mkdir -p /dev/chef/chef-repo/chefconfig"
    only_if { !File.directory?("/dev/chef/chef-repo/chefconfig") }
    action :run 
end

# create local git repository - chefscripts
execute 'create local git repository - chefscripts' do
    user 'devadmin'
    group 'devadmin'
    command "mkdir -p /dev/chef/chef-repo/chefscripts"
    only_if { !File.directory?("/dev/chef/chef-repo/chefscripts") }
    action :run 
end

# synchronize chefconfig
git 'synchronize chefconfig' do
    destination "/dev/chef/chef-repo/chefconfig"
    repository "http://#{git_credential['username']}:#{git_credential['password']}@#{node['git']['base_git_url']}/chefconfig"
    revision 'master'
    action :sync
    user 'devadmin'
    group 'devadmin'
end

# synchronize chefscripts
git 'synchronize chefscripts' do
    destination "/dev/chef/chef-repo/chefscripts"
    repository "http://#{git_credential['username']}:#{git_credential['password']}@#{node['git']['base_git_url']}/chefscripts"
    revision 'master'
    action :sync
    user 'devadmin'
    group 'devadmin'
    notifies :run, 'execute[upload latest cookbooks to chefserver]', :immediately
end

# upload latest cookbooks to chefserver
execute 'upload latest cookbooks to chefserver' do 
    user 'root'
    group 'root'
    command "knife cookbook upload -a"
    action :nothing
end
