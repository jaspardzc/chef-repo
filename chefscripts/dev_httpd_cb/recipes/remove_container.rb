####################################################################################
# Cookbook Name: dev_httpd_cb
# Recipe:: remove_container
# Strategy: remove the httpd container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import removable httpd container list from node attributes
httpd = node['httpd']['removed']

# remove the containers iteratively
httpd.each do |container|
	# remove container using docker_container resource
	docker_container 'delete_httpd_container' do
	    container_name "#{container['container_name']}"
	    remove_volumes true
	    action :delete
	end
end