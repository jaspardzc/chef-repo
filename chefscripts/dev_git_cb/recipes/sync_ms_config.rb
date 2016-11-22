####################################################################################
# Cookbook Name: dev_git_cb
# Recipe:: sync_ms_config
# Strategy: synchronize latest microservice configurationfiles with remote git
# 			configuration files repository
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/21/2016
# Author: kevin.zeng
#####################################################################################

# import tomcat available container list from node attributes
tomcat = node['tomcat']['available']

# import git repositories data from environment attributes
repositories = node['git']['repositories']

# local variables
config_dir = ""

# get local configuration repository path
ruby_block 'get local configuration repository path' do
	block do
		repositories.each do |repository|
			if repository['name'] == "22710_configurationfiles"
				config_dir = repository['localuri'] + "/service_configs"
			end
		end
	end
	action :run 
end

# update the micoservice configuration files if directory exist
tomcat.each do |container|

	# microservice name
	microservice = container['microservice']['name']
	# microservice appconfig dst directory
	appconfig_dst = container['container_appconfig']

	# delete the old amicroservice appconfig interatively
	directory 'delete the old amicroservice appconfig interatively' do
		owner 'devadmin'
		group 'devadmin'
		mode '0755'
		path "#{appconfig_dst}"
		recursive true
		action :delete 
		only_if { File.directory?("#{appconfig_dst}")}
	end

	# copy from src dir to the dst dir inside container recursively
	execute 'update microservice appconfig interatively' do
		group 'devadmin'
		command lazy { "cp -rf #{config_dir}/#{microservice}/appconfig #{appconfig_dst}" }
		action :run
	end
end