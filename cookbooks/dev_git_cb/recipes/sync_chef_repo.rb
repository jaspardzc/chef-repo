#
# Cookbook Name:: dev_git_cb
# Recipe:: syn_chef_repo
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# read git secret key path
secret_key_path = node['git']['secret_key_path']

# read git remote and local uri
remote_chefrepo_latest = node['git']['remoteuri']
local_chefrepo_latest = node['git']['localuri']

# read git credential from encrypted data bag item
git_credential = data_bag_item("git_bag", "credential", IO.read(secret_key_path))

# create directory is the directory is empty
directory "#{local_chefrepo_latest}" do
    owner 'admin'
    group 'admin'
    action :create
end

# download entire remote chef-repo to local chef repo 
git "#{local_chefrepo_latest}" do
    repository "http://#{git_credential['username']}:#{git_credential['password']}@#{remote_chefrepo_latest}"
    revision 'master'
    action :sync
    user 'admin'
    group 'admin'
end


