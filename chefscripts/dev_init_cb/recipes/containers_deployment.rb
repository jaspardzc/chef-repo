####################################################################################
# Cookbook Name: dev_init_cb
# Recipe:: containers_deployment
# Resources: 
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# manage library dependencies
require_relative "../libraries/containers_util"
require_relative "../libraries/chefnode_util"

# Class Object Initialization
containersUtil = ContainersUtil.new()
chefnodeUtil = ChefnodeUtil.new()

# import containers data from environment and node based attributes
containers = node['vms'][node.name]['containers']

# load artifactory secret key from environment attributes
secret_key_path = node['artifactory']['secret_key_path']

# Read system credential from encrypted data bag item
system_credential = data_bag_item("artifactory_bag", "system_credential", IO.read(secret_key_path))

# load password from platform-dev data bag item
container_password = data_bag_item(node.chef_environment, "password", IO.read("/etc/chef/shared_secret_key"))

# login with admin credential
execute 'login the remote artifactory repository' do
    group 'devadmin'
    command "docker login -u #{system_credential['username']} -p #{system_credential['password']} -e artifactory.service@example.com #{node['artifactory']['base_docker_registry_url']}"
    action :run 
end

# loop for managing containers
containers.each do |container|

    # pulling images from remote repository
    execute "pulling docker image: #{container['name']}" do
        group 'devadmin'
        command "docker pull #{container['container_params']['image']['name']}:#{container['container_params']['image']['tag']}"
        action :run
        notifies :stop, 'docker_container[stop container for removal]', :immediately
    end

    # stop container instance for removal
    docker_container 'stop container for removal' do
        container_name container['name']
        action :nothing
        notifies :delete, 'docker_container[remove container]', :immediately
    end

    # delete container instance
    docker_container 'remove container' do
        container_name container['name']
        remove_volumes true
        action :nothing
    end

    # stop container instance for removal
    docker_container 'stop container if the container params are changed or reinstall container is required' do
        container_name container['name']
        only_if { 
            containersUtil.isContainerParamsChanged(node['node_status'], container) ||
            containersUtil.isContainerReinstallRequired(container)
        }
        action :stop
        notifies :delete, 'docker_container[remove container when reinstall required]', :immediately
    end

    # delete container instance
    docker_container 'remove container when reinstall required' do
        container_name container['name']
        remove_volumes true
        action :nothing
    end

    # create container directory
    directory 'create container directory' do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "/dev/containers/#{container['name']}"
        action :create
    end

    # create container backup directory
    directory 'create container backup directory' do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "/backup/containers/#{container['name']}"
        action :create
    end

    # stop container instance only if the reinstall app is required
    docker_container 'stop container for reinstallation' do
        container_name container['name']
        only_if { container['reinstall_app'] == true }
        action :stop
    end

    # delete cert.lock
    file 'delete cert.lock' do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "/dev/containers/#{container['name']}/cert.lock"
        only_if { container['reinstall_app'] == true }
        action :delete
    end

    # delete install.lock
    file 'delete install.lock' do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "/dev/containers/#{container['name']}/install.lock"
        only_if { container['reinstall_app'] == true }
        action :delete
    end

    # create container_command using containersUtil
    container_command = containersUtil.getContainerCreationCommand( container, node['vms']['domain_name'], container_password)
    # create container instance
    execute "create container instance: #{container['name']}" do
        user 'devadmin'
        group 'devadmin'
        command "#{container_command}"
        only_if {
            containersUtil.isContainerExist(container['name']) == false
        }
        action :run
    end

    # start the container after creation
    docker_container 'start the container after creation' do
        container_name container['name']
        action :start
        notifies :run, 'ruby_block[delay stop container after create]', :immediately
    end

    # ruby block for delay 
    ruby_block 'delay stop container after create' do
        block do
            sleep(container['delay_before_stop'])
        end
        action :nothing
        notifies :stop, 'docker_container[stop container after create]', :immediately
    end
 
    # stop container instance
    docker_container 'stop container after create' do
        container_name container['name']
        action :nothing
    end

    # stop container instance when there is change in the deployable artifact version
    # stop container instance when there is change in the config artifact version
    # stop container instance when there is change in the certifications
    docker_container 'stop container for deployment' do
        container_name container['name']
        only_if {
            chefnodeUtil.isInternalCertificateChanged(node['node_status'], container) ||
            chefnodeUtil.isExternalCertificateChanged(node['node_status'], container) ||
            containersUtil.isDeployableChanged(node['node_status'], container) ||
            containersUtil.isConfigChanged(node['node_status'], container)
        }
        action :stop
    end

    # delete the cert.lock if certificate.pem is updated
    file 'delete cert.lock ' do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "/dev/containers/#{container['name']}/cert.lock"
        only_if { 
            chefnodeUtil.isInternalCertificateChanged(node['node_status'], container) || 
            chefnodeUtil.isExternalCertificateChanged(node['node_status'], container) 
        }
        action :delete
    end
    

    # check if download if required, if required, remove all the old jars
    execute 'remove old deployable' do
        group 'devadmin'
        command "rm -f /dev/containers/#{container['name']}#{container['deployable']['directory']}/*#{container['deployable']['extension']}"
        only_if { 
            containersUtil.isDeployableChanged(node['node_status'], container) || 
            container['reinstall_app'] == true
        }
        action :run
    end

    # Problem Occurred, lazy block is taking the last updated value for every iteration

    deployable_localurl = containersUtil.getDeployableLocalUrl(container)
    deployable_remoteurl = containersUtil.getDeployableRemoteUrl(container, node['artifactory'], system_credential) 
    # download and container deployable artifact
    remote_file "downlod deployable artifact: #{container['deployable']['artifactId']}" do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "#{deployable_localurl}"
        source "#{deployable_remoteurl}"
        action :create
    end

    config_localurl = containersUtil.getConfigLocalUrl(container)
    config_remoteurl = containersUtil.getConfigRemoteUrl(node.chef_environment, container, node['artifactory'], system_credential) 
    # download container config artifact
    remote_file "download config artifact: #{container['config']['artifactId']}" do
        owner 'devadmin'
        group 'devadmin'
        mode '0755'
        path "#{config_localurl}"
        source "#{config_remoteurl}"
        action :create
    end

    # updating the configuration with conditional statement
    if (containersUtil.isConfigChanged(node['node_status'], container) == true) ||
       (container['reinstall_app'] == true)

        # iterate the downloaded config artifact, unzip
        container['config']['directories'].each do |key, directory|

            # delete the old config
            directory 'delete old container config directory' do
                owner 'devadmin'
                group 'devadmin'
                mode '0755'
                path "/dev/containers/#{container['name']}#{directory}/#{key}"
                recursive true
                action :delete
            end

            # unzip 
            execute 'unzip the config directory from config artifact' do
                user 'devadmin'
                group 'devadmin'
                command "unzip #{config_localurl} #{key}/* -d /dev/containers/#{container['name']}#{directory}" 
                action :run 
            end
        end

        # delete the zip file
        file 'delete config artifact' do 
            owner 'devadmin'
            group 'devadmin'
            mode '0755'
            path "#{config_localurl}"
            action :delete 
        end
    end

    # start container instance when there is change in the deployable artifact version
    # start container instance when there is change in the config artifact version
    # start container instance when there is change in the certifications
    docker_container 'start container' do 
        container_name container['name']
        only_if {
            chefnodeUtil.isInternalCertificateChanged(node['node_status'], container) ||
            chefnodeUtil.isExternalCertificateChanged(node['node_status'], container) ||
            containersUtil.isDeployableChanged(node['node_status'], container) ||
            containersUtil.isConfigChanged(node['node_status'], container) ||
            container['reinstall_app'] == true
        }
        action :start
    end

    # set node status per container
    ruby_block 'set node status per container' do
        block do
            node.normal['node_status']['containers']["#{container['name']}"]['external_certs_status'] = "applied";
            node.normal['node_status']['containers']["#{container['name']}"]['internal_certs_status'] = "applied";
            node.normal['node_status']['containers']["#{container['name']}"]['current_deployable'] = container['deployable']
            node.normal['node_status']['containers']["#{container['name']}"]['current_config'] = container['config']
            node.normal['node_status']['containers']["#{container['name']}"]['current_container_params'] = container['container_params']
        end
        action :run
    end
end

# set node status
ruby_block 'set node status' do
    block do
        node.normal['node_status']['current_container_set'] = chefnodeUtil.getNodeContainerName(containers).to_a
    end
    action :run
end