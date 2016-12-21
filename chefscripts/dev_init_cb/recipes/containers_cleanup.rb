####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: containers_cleanup
# Resources: remove containers on the host machine based on latest environment attrs
#   		 delete containers directory on the host machine
#   		 delete cintainers back directory on the host machine
#   		 cleanup node normal attributes
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# manage library dependencies
require 'set'
require_relative "../libraries/containers_util"

# Class Object Initialization
containersUtil = ContainersUtil.new()

# decommision containers based on the differences betweeen node containers set and env 
# containers set

if defined?node['node_status']['current_containerSet']

	current_containerSet = node['node_status']['current_container_set'].to_set

	tobe_containerSet = containersUtil.getNodeContainerName(node['vms'][node.name]['containers'])

	decommision_containerSet = current_containerSet - tobe_containerSet

	decommision_containerSet.each do |container| 
		# remove containers
		docker_container "remove container: #{container}" do
			container_name container
			remove_volumes true
			action :delete
		end
		# remove container dev directory
		directory 'remove container dev directory' do
	        owner 'devadmin'
	        group 'devadmin'
	        mode '0755'
	        path "/dev/containers/#{container}"
			recursive true
			action :delete
		end
		# remove container backup directory
		directory 'remove container backup directory' do
	        owner 'devadmin'
	        group 'devadmin'
	        mode '0755'
	        path "/backup/containers/#{container}"
			recursive true
			action :delete
		end
		# cleanup node status
		ruby_block 'cleanup node status per container' do
			block do
	            node.normal['node_status']['containers'][container['name']] = {
	                    "external_certs_status": "",
	                    "internal_certs_status": "",
	                    "current_deployable": {},
	                    "current_config": {},
	                    "current_container_params": {}
	                }
			end
		end
	end
end