####################################################################################
# Cookbook Name: dev_restseed_cb
# Recipe:: donwload.rb
# Strategy: download artifact based on specific version
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# manage required dependencies
require_relative '../../dev_artifactory_cb/libraries/download_manager'

# Instantiate Local Variables
localuri = DownloadManager.getLocalUri()
remoteuri = DownloadManager.getRemoteUri()

# Read Artifactory Secret Key path
secret_key_path = node['artifactory']['secret_key_path']

# Read system credential from encrypted data bag item
system_credential = data_bag_item("artifactory_bag", "system_credential", IO.read(secret_key_path))

# Concatnate system credential with the remoteuri
remoteuri = system_credential['username'] + ":" + system_credential['password'] + "@" + remoteuri

# Main Resource for artifact downloading 
remote_file "#{localuri}" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    source "http://#{remoteuri}"
	action :create
end
