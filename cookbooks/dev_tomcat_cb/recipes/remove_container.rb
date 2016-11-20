####################################################################################
# Cookbook Name: dev_tomcat_cb
# Recipe:: remove_container
# Strategy: remove the tomcat container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import removable tomcat container list from node attributes
tomcat = node['tomcat']['removed']

# remove the containers iteratively
tomcat.each do |container|
	# remove container using docker_container resource
	docker_container 'delete_tomcat_container' do
	    container_name "#{container['container_name']}"
	    remove_volumes true
	    action :delete
	end
end