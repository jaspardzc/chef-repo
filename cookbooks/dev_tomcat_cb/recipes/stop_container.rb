#
# Cookbook Name: dev_tomcat_cb
# Recipe:: stop_container
# 
# Copyright (c) 2016 The Auhtors, All Rights Reserved

# Manage required dependencies
require 'docker'

# get container name from environemnt attribute
container_name = node['tomcat']['container']['name']
container_network = node['tomcat']['container']['network']

# stop container using docker_container resource 
docker_container 'stop_tomcat_container' do
    container_name "#{container_name}"
    network_mode "#{container_network}"
    action :stop
end
