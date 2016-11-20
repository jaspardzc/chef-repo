####################################################################################
# Cookbook Name: dev_springboot_cb
# Recipe:: create_container
# Strategy: create the springboot container iteratively, skip if container already exists
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available springboot container list from node attributes
springboot = node['springboot']['available']

# create the containers iteratively
springboot.each do |container|
  # using docker resource to create new docker container
  docker_container "create_springboot_container: #{container['container_name']}" do
    container_name "#{container['container_name']}"
    repo 'DEV-NODE-050.com.demo:8082/stdspringbootbox'
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
    env ['JAVA_MEM_OPTS=-Xms1024m -Xmx4096m -XX:MaxPermSize=512m', 'JAVA_OTH_OPTS=-Denv=prod']
    action :create
  end
end
