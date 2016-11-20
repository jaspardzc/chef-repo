####################################################################################
# Cookbook Name: dev_mongodb_cb
# Recipe:: stop_container
# Strategy: stop the mongodb container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available mongodb container list from node attributes
mongodb = node['mongodb']['available']

# stop the containers if the webapp version is outdated
mongodb.each do |container|
	# stop container using docker_container resource 
	docker_container 'stop_mongodb_container' do
	    container_name "#{container['container_name']}"
	    network_mode "#{container['container_network']}"
	    action :stop
	end
end

