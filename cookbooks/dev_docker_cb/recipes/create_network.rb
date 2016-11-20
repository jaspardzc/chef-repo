####################################################################################
# Cookbook Name: dev_docker_cb
# Recipe:: create_network
# Strategy: create docker networks
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################


# Manage dependencies
require 'docker'

# Local Variables
server_net = "lcl-net-server"
app_net = "lcl-net-app"
db_net = "lcl-net-db"

# create server network
docker_network "#{server_net}" do
    subnet '172.20.0.0/16'
    gateway '172.20.0.1/16'
    action :create
end

# create app network
docker_network "#{app_net}" do
    subnet '172.21.0.0/16'
    gateway '172.21.0.1/16'
    action :create
end

# create db network
docker_network "#{db_net}" do
    subnet '172.22.0.0/16'
    gateway '172.22.0.1/16'
    action :create
end
