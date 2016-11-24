####################################################################################
# Cookbook Name: dev_git_cb
# Recipe:: upload_chefnodes
# Strategy: upload chefnodes from chefdk to chef server, which will automatically
# 			update all chef server data about nodes, environments, roles
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/23/2016
# Author: kevin.zeng
#####################################################################################

# import ruby library dependencies
require 'json'

# import git repositories data from node attributes
repositories = node['git']['repositories']

# local variables
node_local_repo = ""
node_local_repo_roles = ""
node_local_repo_envs = ""
node_chef_env = ""
node_runlist = ""
node_normal_attrs = ""

# ruby block
ruby_block 'load latest chef node properties' do
	block do
		# find the local repository contains node related files
		repositories.each do |repository|
			if repository['name'] == "chefconfig"
				node_local_repo = repository['localuri']
			end
			break
		end
		# read the chef node properties from chef node local node repository
		filenames = Dir.glob("#{node_local_repo}/nodes/**/*")
		filenames.each do |filename| 
			name = String.new("#{filename}")
			pattern = String.new("#{node['name']}")
			if name.include?pattern
				file = open("#{filename}")
				file_json = file.read
				file_parsed = JSON.parse(file_json)
				node_chef_env = file_parsed['chef_environment']
				node_runlist = file_parsed['run_list']
				node_normal_attrs = file_parsed['normal']
			end
		end
	end
end

# chef_node resource, update curent local node
chef_node "#{node.name}" do
	chef_environment lazy { node_chef_env }
	run_list lazy { node_runlist } 
	normal_attributes lazy { node_normal_attrs }
end

# chef_role resource, update all available chef environments iteratively
node_local_repo_envs = lambda { Dir.glob("#{node_local_repo}/environments/**/*") }
node_local_repo_envs.call.each do |env|
	execute 'update all chef environments' do
		group 'devadmin'
		command "knife environment from file #{env}"
		action :run
	end
end

# chef_role resource, update all available chef roles iteratively
node_local_repo_roles = lambda { Dir.glob("#{node_local_repo}/roles/**/*") }
node_local_repo_roles.call.each do |role|
	execute 'update all chef roles' do
		group 'devadmin'
		command "knife role from file #{role}"
		action :run
	end
end