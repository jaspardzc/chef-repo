#
# Cookbook Name: dev_mongodb_cb
# Recipe:: remove_container
# 
# Copyright (c) 2016 The Auhtors, All Rights Reserved

# Manage required dependencies
require 'docker'

# Get Tomcat Container by container id
container_name = node['mongodb']['container']['name']

# remove container using docker_container resource
docker_container 'delete_mongodb_container' do
    container_name "#{container_name}"
    remove_volumes true
    action :delete
end
