####################################################################################
# Cookbook Name: dev_restseed_cb
# Recipe:: default.rb
# Strategy: init recipe of restseed cookbook, concat parameters for other recipes
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# manage required dependencies
require_relative '../../dev_artifactory_cb/libraries/download_manager'

# local variables
ms_warpath = ""
ms_name = ""
ms_version = ""
ms_snapshot = ""

# import available tomcat container list from node attributes
tomcat = node['tomcat']['available']

# iterate the tomcat container list and find matching microservice
tomcat.each do |container|
	if container['microservice']['name'] == "restseed-web"
		ms_warpath = container['container_webapp']
		ms_name = container['microservice']['name']
		ms_version = container['microservice']['version']
		ms_snapshot = container['microservice']['snapshot']
	end
end

# import artifactory data from environment attributes
artifactory_hostname = node['artifactory']['hostname']
artifactory_port = node['artifactory']['port']
artifactory_baseuri = node['artifactory']['baseuri']


# concat the _localuri and _remoteuri
_localuri = ms_warpath + "/" + ms_name + "-" + ms_version + ".war"

_remoteuri = artifactory_hostname + ":" + artifactory_port + "/" + artifactory_baseuri + "/" + ms_name + "/" + ms_snapshot + "/" + ms_name + "-" + ms_version + ".war"

_localmeta = ms_warpath + "/"

_remotemeta = artifactory_hostname + ":" + artifactory_port + "/" + artifactory_baseuri + "/" + ms_name + "/" + ms_snapshot + "/"

# invoke the default constructor of Download Manager
DownloadManager.new(_localuri, _remoteuri, _localmeta, _remotemeta)


