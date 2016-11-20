####################################################################################
# Cookbook Name: dev_restseed_cb
# Recipe:: donwload_latest.rb
# Strategy: download latest version artifact
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# manage required dependencies
require_relative '../../dev_artifactory_cb/libraries/download_manager'

# local variables
ms_snapshot = ""

# import available tomcat container list from node attributes
tomcat = node['tomcat']['available']

# iterate the tomcat container list and find matching microservice
tomcat.each do |container|
    if container['microservice']['name'] == "restseed-web"
        ms_snapshot = container['microservice']['snapshot']
    end
end

# Read Artifactory Secret Key path
secret_key_path = node['artifactory']['secret_key_path']

# Read system credential from encrypted data bag item
system_credential = data_bag_item("artifactory_bag", "system_credential", IO.read(secret_key_path))

# Instantiate Local Variables
localmeta = DownloadManager.getLocalMeta()
remotemeta = DownloadManager.getRemoteMeta()
remotemeta = system_credential['username'] + ":" + system_credential['password'] + "@" + remotemeta
remoteuri = ""
localuri = ""

# Init Logging Info
Chef::Log.info("Start downloading latest artifadev from Jfrog remote artifactory repository.....")

# download metadata to temporary directory for further processing
remote_file "/tmp/#{ms_snapshot}" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    source "http://#{remotemeta}"
    action :create
end

# Ruby Block
ruby_block 'set_artifact_latest_version' do
    block do
        # set the latest version of the artifact
        DownloadManager.setLatestVersion(ms_snapshot)

        # concat the remote uri using remotemeta and latest_version
        latest_version = DownloadManager.getLatestVersion()
        remoteuri = remotemeta + latest_version
        localuri = localmeta + latest_version
    end
    action :run
end

# Resource to download the latest artifact 
remote_file "download_latest_artifact" do
	owner 'devadmin'
    group 'devadmin'
    mode '0755'
    path lazy { "#{localuri}" }
    source lazy { "http://#{remoteuri}" }
	action :nothing
    subscribes :create, 'ruby_block[set_artifact_latest_version]', :immediately
end

# delete the temporary file
file "/tmp/#{ms_snapshot}" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    action :delete
end

# Exit Logging Info
Chef::Log.info("Sucessfully downloaded latest artifactory from Jfrog remote artifactory repository.....")

