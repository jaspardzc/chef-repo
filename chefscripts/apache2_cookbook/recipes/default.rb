#
# Cookbook Name:: apache2_cookbook
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# update the apt cache every 24 hours
apt_update 'update the apt cache daily' do
	frequency 86_400
	action :periodic
end

# package install
package 'apache2'


# service lifecycle management
service 'apache2' do
	# helps chef use the appropriate strategy to determine if the apache service is running or not
	supports :status => true
	action [ :enable, :start]
end


# home page for the server
template '/var/www/html/index.html' do
	source 'index.html.erb'
end


