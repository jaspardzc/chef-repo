####################################################################################
# Cookbook Name: dev_springboot_cb
# Recipe:: stop_container
# Strategy: stop the springboot container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available springboot container list from node attributes
springboot = node['springboot']['available']

# stop the containers if the webapp version is outdated
springboot.each do |container|
	# stop container using docker_container resource 
	docker_container 'stop_springboot_container' do
	    container_name "#{container['container_name']}"
	    network_mode "#{container['container_network']}"
	    kill_after 10
	    action :stop
	end
end

