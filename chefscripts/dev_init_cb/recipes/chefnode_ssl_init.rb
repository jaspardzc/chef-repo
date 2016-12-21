####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: chefnode_ssl_init
# Resources: download ssl certs from remote private Git SCM Repository
#  
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# import containers data from environment and node based attributes
containers = node['vms'][node.name]['containers']

# create ssl external and internal directory
execute 'create ssl directory' do 
    user 'devadmin'
    group 'devadmin'
    command "mkdir -p /dev/containers/certs/internal\
        && mkdir -p /dev/containers/certs/external"
    only_if { !File.directory?("/dev/containers/certs") }
    action :run
end

# update ssl internal private key
remote_file 'update ssl internal private key' do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    path "/dev/containers/certs/internal/private.key"
    source "file:///dev/chef/env_configuration/ssl_certs/internal/private.key"
    action :create 
end

# update ssl internal public crt
remote_file 'update ssl internal public crt' do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    path "/dev/containers/certs/internal/public.crt"
    source "file:///dev/chef/env_configuration/ssl_certs/internal/public.crt"
    action :create 
    notifies :run, 'execute[create internal certificate.pem]', :immediately
end

# create the internal certificate.pem
execute 'create internal certificate.pem' do
    user 'devadmin'
    group 'devadmin'
    command "cat /dev/containers/certs/internal/public.crt /dev/containers/certs/internal/private.key > /dev/containers/certs/internal/certificate.pem"
    action :nothing
    notifies :run, 'ruby_block[set internal certificate upgrade status]', :immediately
end

# set internal certificate upgrade status per container
ruby_block 'set internal certificate upgrade status' do
    block do
        containers.each do |container|
            node.normal['node_status']['containers']["#{container['name']}"]['internal_certs_status'] = "received";
        end
    end
    action :nothing
end

# update ssl external private key
remote_file 'update ssl external private key' do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    path "/dev/containers/certs/external/private.key"
    source "file:///dev/chef/env_configuration/ssl_certs/external/private.key"
    action :create 
end

# update ssl external public crt
remote_file 'update ssl external public crt' do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    path "/dev/containers/certs/external/public.crt"
    source "file:///dev/chef/env_configuration/ssl_certs/external/public.crt"
    action :create 
    notifies :run, 'execute[create external certificate.pem]', :immediately
end

# create the external certificate.pem
execute 'create external certificate.pem' do
    user 'devadmin'
    group 'devadmin'
    command "cat /dev/containers/certs/external/public.crt /dev/containers/certs/external/private.key > /dev/containers/certs/external/certificate.pem"
    action :nothing
end

# set external certificate upgrade status per container
ruby_block 'set external certificate upgrade status' do
    block do
        containers.each do |container|
            node.normal['node_status']['containers']["#{container['name']}"]['external_certs_status'] = "received";
        end
    end
    action :nothing
end