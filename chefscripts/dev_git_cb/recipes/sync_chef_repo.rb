####################################################################################
# Cookbook Name: dev_git_cb
# Recipe:: sync_chef_repo
# Strategy: synchronize chef dk local repository with remote git repository
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/20/2016
# Author: kevin.zeng
#####################################################################################

# import git repositories data from environment attributes
repositories = node['git']['repositories']

# read git secret key path
secret_key_path = node['git']['secret_key_path']

# read git credential from encrypted data bag item
git_credential = data_bag_item("git_bag", "credential", IO.read(secret_key_path))

# synchronize remote git repositories iteratively
repositories.each do |repository|

    # create local git repository if does not exist
    directory 'create local git repository' do
        path "#{repository['localuri']}"
        owner 'devadmin'
        group 'devadmin'
        action :create
    end

    # synchronize local_git_repo with remote_git_repo 
    git 'synchronize_local_git_repo_with_remote_git_repo' do
        destination "#{repository['localuri']}"
        repository "http://#{git_credential['username']}:#{git_credential['password']}@#{repository['remoteuri']}"
        revision 'master'
        action :sync
        user 'devadmin'
        group 'devadmin'
    end
end
