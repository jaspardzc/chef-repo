####################################################################################
# Cookbook Name: dev_git_cb
# Recipe:: sync_chef_repo
# Strategy: synchronize chef dk local repository with remote git chef repo
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# read git secret key path
secret_key_path = node['git']['secret_key_path']

# read git remote and local uri
remote_chefrepo_latest = node['git']['remoteuri']
local_chefrepo_latest = node['git']['localuri']

# read git credential from encrypted data bag item
git_credential = data_bag_item("git_bag", "credential", IO.read(secret_key_path))

# create directory is the directory is empty
directory "#{local_chefrepo_latest}" do
    owner 'devadmin'
    group 'devadmin'
    action :create
end

# download entire remote chef-repo to local chef repo 
git "#{local_chefrepo_latest}" do
    repository "http://#{git_credential['username']}:#{git_credential['password']}@#{remote_chefrepo_latest}"
    revision 'master'
    action :sync
    user 'devadmin'
    group 'devadmin'
end


