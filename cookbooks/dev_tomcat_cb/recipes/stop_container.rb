####################################################################################
# Cookbook Name: dev_tomcat_cb
# Recipe:: stop_container
# Strategy: stop the tomcat container iteratively if webapp version is outdated
#           clean the tomcat container webapp folder if webapp version is outdated
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available tomcat container list from node attributes
tomcat = node['tomcat']['available']

# stop the containers if the webapp version is outdated
tomcat.each do |container|
	# Method to check if container artifact version is the same as the version declared in the node attribute
	artifact_version_same = !Dir.glob("#{container['container_webapp']}*-#{container['microservice']['version']}.war").empty? 

	if artifact_version_same
		# logging information
		Chef::Log.info("Container #{container['container_name']} has latest artifact [update-to-date]")
	else 
		# stop container using docker_container resource 
		docker_container 'stop_tomcat_container' do
		    container_name "#{container['container_name']}"
		    network_mode "#{container['container_network']}"
		    action :stop
		end
		# If version is not the same, remove all the artifadev from tomcat container
		directory "#{container['container_webapp']}" do
			owner 'devadmin'
			group 'devadmin'
			recursive true
			action [ :delete, :create]
		end
	end
end