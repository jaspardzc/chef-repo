#
# Cookbook Name:: dev_springboot_cb
# Recipe:: start_container
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Manage required dependencies
require 'docker'

# Get Mongod container by container name
container_name = node['springboot']['container']['name']
container_network = node['springboot']['container']['network']

# start container using docker_container resource
docker_container 'start_springboot_container' do
    container_name "#{container_name}"
    network_mode "#{container_network}"
    action :start
end
