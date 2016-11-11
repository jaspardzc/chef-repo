#
# Cookbook Name:: dev_tomcat_cb
# Recipe:: update_war
#
# Copyright (c) 2016 The Authors, All Rights Reserved

# Manage required dependencies
require 'pathname'

# Init Logging Info
Chef::Log.info("Matching the Tomcat Container artifact version with artifact version declared in the Node Attribute...")

# Method to check if container artifact version is the same as the version declared in the node attribute
artifact_version_same = !Dir.glob("#{node['tomcat']['warpath']}*-#{node['microservice']['version']}.war").empty? 

if artifact_version_same
    # If version is the same, skipped the following steps
    Chef::Log.info("The artifact version in the container is already up-to-date....")
else 
    # If version is not the same
    Chef::Log.info("New Artifact version has been detected based on Node Attribute....")
    Chef::Log.info("Removing Old Artifacts from Tomcat Container....")

    # Resource to remove all the artifacts from tomcat container
    directory "#{node['tomcat']['warpath']}" do
        owner 'admin'
        group 'admin'
        recursive true
        action [ :delete, :create]
    end
    Chef::Log.info("Successfully removed all the artifacts from the container....")
end




