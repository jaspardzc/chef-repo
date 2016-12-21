####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: chefnode_directories_init
# Resources: create containers root directory in the host machine
#    		 create containers backup directory in the host machine
#    		 create environment config root directory in the host machine
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# create containers root directory
directory '/dev/containers' do
	owner 'devadmin'
	group 'devadmin'
	mode '0755'
	action [ :create]
end

# create containers backup directory
directory '/backup/containers' do
	owner 'devadmin'
	group 'devadmin'
	mode '0755'
	action [ :create]
end
