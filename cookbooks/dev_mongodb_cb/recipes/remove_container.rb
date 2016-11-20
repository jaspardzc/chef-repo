####################################################################################
# Cookbook Name: dev_mongodb_cb
# Recipe:: remove_container
# Strategy: remove the mongodb container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import removable mongodb container list from node attributes
mongodb = node['mongodb']['removed']

# remove the containers iteratively
mongodb.each do |container|
	# remove container using docker_container resource
	docker_container 'delete_mongodb_container' do
	    container_name "#{container['container_name']}"
	    remove_volumes true
	    action :delete
	end
end

