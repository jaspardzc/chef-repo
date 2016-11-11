#
# Cookbook Name: dev_httpd_cb
# Recipe:: stop_container
# 
# Copyright (c) 2016 The Auhtors, All Rights Reserved

# Manage required dependencies
require 'docker'

# Get Tomcat Container by container id
container_name = node['httpd']['container']['name']
container_network = node['httpd']['container']['network']

# stop the container using docker_container resource
docker_container 'stop_httpd_container' do
    container_name "#{container_name}"
    network_mode "#{container_network}"
    action :stop
end

