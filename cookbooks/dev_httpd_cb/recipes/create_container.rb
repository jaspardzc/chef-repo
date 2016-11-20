####################################################################################
# Cookbook Name: dev_httpd_cb
# Recipe:: create_container
# Strategy: create the httpd container iteratively, skip if container already exists
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available httpd container list from node attributes
httpd = node['httpd']['available']

# create the containers iteratively
httpd.each do |container|
  # using docker resource to create new docker container
  docker_container "create_httpd_container: #{container['container_name']}" do
    container_name "#{container['container_name']}"
    repo 'DEV-NODE-050.com.demo:8082/stdhttpdbox'
    tag '1.0'
    host_name "#{container['container_name']}.ssphosting.net"
    memory Integer('4000000000')
    memory_swap Integer('5000000000')
    open_stdin true
    tty true
    user 'devadmin'
    port "#{container['container_port']}"
    volumes ["/dev/containers/certs:/devcerts", "/dev/containers/#{container['container_name']}:/devext", "/backup/containers/#{container['container_name']}:/backup"]
    network_disabled false
    network_mode "#{container['container_network']}"
    log_opts ['max-size=2m']
    action :create
  end
end