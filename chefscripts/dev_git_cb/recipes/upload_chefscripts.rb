####################################################################################
# Cookbook Name: dev_git_cb
# Recipe:: upload_chefscripts
# Strategy: upload chefscripts from chefdk to chef server, which will automatically
# 			update all chef server hosted cookbooks
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/23/2016
# Author: kevin.zeng
#####################################################################################

# import git repository data from node attributes
repositories = node['git']['repositories']

# local variable
cookbooks_dir = ""

# ruby block to get the cookbooks directory on chef dk
ruby_block 'get cookbooks directory' do
	block do
		repositories.each do |repository|
			if repository['name'] == "chefscripts"
				cookbooks_dir = repository['localuri'] + "/cookbooks"
			end
		end
	end
	action :run
end

# considering using knife cookbook upload -a -E ENV_NAME to upload all cookbooks
# to specific environments

# upload all available tranzform cookbooks to the chef server iteratively
cookbooknames = lambda { Dir.glob("#{cookbooks_dir}/**/") }
cookbooknames.call.each do |cookbookname|
	name = String.new("#{cookbookname}")
	prefix = String.new("dev_")
	if name.include?prefix
		execute 'update tranzform cookbooks' do
			group 'devadmin'
			command "knife cookbook upload #{cookbookname}"
			action :run
		end
	end
end


# upload all community cookbooks to the chef server 
# with specific community  cookbook name
execute 'update community cookbooks' do
	group 'devadmin'
	command "knife cookbook upload /home/devadmin/chef-repo/chefscripts/cookbooks/compat_resource \
	&& knife cookbook upload /home/devadmin/chef-repo/chefscripts/cookbooks/docker_cookbook"
	action :run
end