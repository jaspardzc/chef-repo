####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: chefnode_networks_init
# Resources: create docker networks in the host machine
#            subnet port and gateway port will be auto-allocated
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# create docker network
docker_network 'dev-net' do
	action :create
end

# create docker network
docker_network 'dev-net-db' do
	action :create
end

# create docker network
docker_network 'dev-net-external' do
	action :create
end