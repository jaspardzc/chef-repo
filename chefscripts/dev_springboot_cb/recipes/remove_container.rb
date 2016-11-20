####################################################################################
# Cookbook Name: dev_springboot_cb
# Recipe:: remove_container
# Strategy: remove the springboot container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import removable springboot container list from node attributes
springboot = node['springboot']['removed']

# remove the containers iteratively
springboot.each do |container|
	# remove container using docker_container resource
	docker_container 'delete_springboot_container' do
	    container_name "#{container['container_name']}"
	    remove_volumes true
	    action :delete
	end
end

