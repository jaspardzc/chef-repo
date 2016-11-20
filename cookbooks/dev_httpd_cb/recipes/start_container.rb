####################################################################################
# Cookbook Name: dev_httpd_cb
# Recipe:: start_container
# Strategy: start the httpd container iteratively
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available httpd container list from node attributes
httpd = node['httpd']['available']

# stop the containers if the webapp version is outdated
httpd.each do |container|
	# start the container using docker_container resource
	docker_container 'start_httpd_container' do
	    container_name "#{container['container_name']}"
	    network_mode "#{container['container_network']}"
	    action :start
	end
end