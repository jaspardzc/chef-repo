#
# Cookbook Name: dev_tomcat_cb
# Recipe:: create_container
# 
# Copyright (c) 2016 The Auhtors, All Rights Reserved

# Manage required dependencies
require 'docker'

# Get Tomcat Container by container id
container_name = node['tomcat']['container']['name']
container_network = node['tomcat']['container']['network']

# using docker resource to create new docker container
docker_container 'create_tomcat_container' do
  container_name "#{container_name}"
  repo 'DEV-050.node:8082/stdtomcatbox'
  tag '2.0'
  memory Integer('4000000000')
  memory_swap Integer('5000000000')
  volumes ['/dev/containers/certs:/devcerts', '/dev/containers/lcl-cnt-svc-002:/devext', '/backup/containers/lcl-cnt-svc-002:/backup']
  network_disabled false
  network_mode "#{container_network}"
  port '28443:8443'
  publish_all_ports true
  tty true
  user 'admin'
  host_name 'lcl-cnt-svc-002.ssphosting.net'
  log_opts 'max-size=2m'
  env ['JAVA_MEM_OPTS=-Xms512m -Xmx1024m', 'JAVA_OTH_OPTS=-Denv=prod -DlogBasePath=/devext/softwares/tomcat-a/logs']
  command '/dev/scripts/startup'
  action :run_if_missing
end

