#
# Cookbook Name:: dev_idcard_Cb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved

# manage required dependencies
require_relative '../../dev_artifactory_cb/libraries/download_manager'

# initalize local variables with node attributes
ms_warpath = node['tomcat']['warpath']
ms_name = node['microservice']['name']
ms_version = node['microservice']['version']
ms_snapshot = node['microservice']['snapshot']

artifactory_hostname = node['artifactory']['hostname']
artifactory_port = node['artifactory']['port']
artifactory_baseuri = node['artifactory']['baseuri']


# concat the _localuri and _remoteuri
_localuri = ms_warpath + "/" + ms_name + "-" + ms_version + ".war"

_remoteuri = artifactory_hostname + ":" + artifactory_port + "/" + artifactory_baseuri + "/" + ms_name + "/" + ms_snapshot + "/" + ms_name + "-" + ms_version + ".war"

_localmeta = ms_warpath + "/"

_remotemeta = artifactory_hostname + ":" + artifactory_port + "/" + artifactory_baseuri + "/" + ms_name + "/" + ms_snapshot + "/"

# invoke the default constructor of Download Manager
dm = DownloadManager.new(_localuri, _remoteuri, _localmeta, _remotemeta)


