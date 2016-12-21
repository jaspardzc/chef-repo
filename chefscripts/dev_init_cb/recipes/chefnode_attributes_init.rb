####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: chefnode_attributes_init
# Resources: initialize node normal attributes
# 
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# import containers data from environment and node based attributes
containers = node['vms'][node.name]['containers']

# initialize node status
ruby_block 'initialize node status' do
    block do
    	if node['node_status'] == nil
        	node.normal['node_status']['containers'] = {}
        	node.normal['node_status']['current_container_set'] = []
    	end
        containers.each do |container|
        	if node['node_status']['containers'][container['name']] == nil
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
    action :run
end