####################################################################################
# Cookbook Name: dev_init_cb
# Library:: containers_util
# Methods: getDeployableLocalUrl
#          getDeployableRemoteUrl
#          getConfigLocalUrl
#          getConfigRemoteUrl
#          isDeployableChanged
#          isConfigChanged
#          isArtifactSame
#          isContainerParamsChanged
#          isContainerReinstallRequired
#          isContainerExist
#          getContainerCreationCommand
#          replaceStringBasedOnRegex
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 12/20/2016
# Author: kevin.zeng
#####################################################################################

# manage dependencies
require 'docker'
require 'set'

class ContainerStateManager 

    # default reserved constructor
    def initialize ()
        # empty
    end

    # accessor for deployable localurl
    def getDeployableLocalUrl ( container )

            if container['deployable']['datestamp'] == ""
               deployable_localurl = "/dev/containers/#{container['name']}#{container['deployable']['directory']}/#{container['deployable']['artifactId']}-#{container['deployable']['version']}#{container['deployable']['extension']}"
            else
               deployable_localurl = "/dev/containers/#{container['name']}#{container['deployable']['directory']}/#{container['deployable']['artifactId']}-#{container['deployable']['version']}-#{container['deployable']['datestamp']}#{container['deployable']['extension']}"
            end

            return deployable_localurl
    end

    # accessor for deployable remoteurl
    def getDeployableRemoteUrl ( container, artifactory, credential )
        
            if container['deployable']['datestamp'] == ""
                deployable_remoteurl = "#{artifactory['hostname']}:#{artifactory['port']}/#{artifactory['base_release_url']}/#{container['deployable']['groupId']}#{container['deployable']['artifactId']}/#{container['deployable']['version']}/#{container['deployable']['artifactId']}-#{container['deployable']['version']}#{container['deployable']['extension']}"
            else
                deployable_remoteurl = "#{artifactory['hostname']}:#{artifactory['port']}/#{artifactory['base_snapshot_url']}/#{container['deployable']['groupId']}#{container['deployable']['artifactId']}/#{container['deployable']['version']}-SNAPSHOT/#{container['deployable']['artifactId']}-#{container['deployable']['version']}-#{container['deployable']['datestamp']}#{container['deployable']['extension']}"
            end

            deployable_remoteurl = "http://#{credential['username']}:#{credential['password']}@#{deployable_remoteurl}"
            return deployable_remoteurl
    end

    # accessor for config localurl
    def getConfigLocalUrl ( container )

            if container['config']['datestamp'] == ""
               config_localurl = "/dev/containers/#{container['name']}/#{container['name']}-#{container['config']['version']}#{container['config']['extension']}"
            else 
               config_localurl = "/dev/containers/#{container['name']}/#{container['name']}-#{container['config']['version']}-#{container['config']['datestamp']}#{container['config']['extension']}"
            end
            return config_localurl
    end

    # accessor for config remoteurl
    def getConfigRemoteUrl ( env, container, artifactory, credential )
            
            if container['config']['datestamp'] == ""
                config_remoteurl = "#{artifactory['hostname']}:#{artifactory['port']}/#{artifactory['base_release_url']}/#{container['config']['groupId']}#{env}/#{container['name']}/#{container['config']['version']}/#{container['name']}-#{container['config']['version']}#{container['config']['extension']}"
            else 
                config_remoteurl = "#{artifactory['hostname']}:#{artifactory['port']}/#{artifactory['base_snapshot_url']}/#{container['config']['groupId']}#{env}/#{container['name']}/#{container['config']['version']}-SNAPSHOT/#{container['name']}-#{container['config']['version']}-#{container['config']['datestamp']}#{container['config']['extension']}"
            end

            config_remoteurl = "http://#{credential['username']}:#{credential['password']}@#{config_remoteurl}"
            return config_remoteurl
    end

    # check if container deployable data is changed
    def isDeployableChanged ( currentState, toBeState )
        if (defined?currentState['containers']["#{toBeState['name']}"]['current_deployable']) &&
           (defined?toBeState['deployable']) &&
           (defined?currentState['containers']["#{toBeState['name']}"]['current_deployable']['groupId'])
            return isArtifactSame(currentState['containers']["#{toBeState['name']}"]['current_deployable'], toBeState['deployable'])
        else
            return true
        end
    end

    # check if container config data is changed
    def isConfigChanged ( currentState, toBeState ) 
        if (defined?currentState['containers']["#{toBeState['name']}"]['current_config']) &&
           (defined?toBeState['config']) &&
           (defined?currentState['containers']["#{toBeState['name']}"]['current_config']['groupId'])
            return isArtifactSame(currentState['containers']["#{toBeState['name']}"]['current_config'], toBeState['config'])
        else
            return true
        end
    end

    # util method for checking if artifact data is outdated 
    def isArtifactSame ( currentArtifact, toBeArtifact ) 
        if (currentArtifact['groupId'] == toBeArtifact['groupId']) &&
           (currentArtifact['artifactId'] == toBeArtifact['artifactId']) &&
           (currentArtifact['version'] == toBeArtifact['version']) &&
           (currentArtifact['datestamp'] == toBeArtifact['datestamp']) &&
           (currentArtifact['extension'] == toBeArtifact['extension'])
            return true
        else 
            return false
        end
    end

    # check if container parameters are outdated
    def isContainerParamsChanged ( currentState, toBeState) 
        if (defined?currentState['containers']["#{toBeState['name']}"]['current_container_params'])
            if currentState['containers']["#{toBeState['name']}"]['current_container_params'].eql?toBeState['container_params']
                return false
            else
                return true
            end
        end
    end

    # check if container resintallation is required
    def isContainerReinstallRequired( container )
        return container['reinstall_container']
    end

    # check if container exist
    def isContainerExist( name )
        begin
            container = Docker::Container.get(name)
            return true
        rescue
            puts "Container with name: #{name} does not exist."
            return false
        end
    end

    # create contaienr creation command based on container object and vms domain name
    def getContainerCreationCommand( container, domain_name, password )
        # local variables
        port_string = ""
        env_string = ""
        command = ""
        # get container ports 
        container_ports = container['container_params']['port']
        # get container env opts
        container_env = container['container_params']['env']
        # create dynamic port string
        container_ports.each do |port|
            port_string = "#{port_string}-p #{port} "
        end
        # create dynamic environment string
        container_env.each do |env|
            # regular expression for the container password
            regex = /~\S*~/
            # the password placeholder string 
            key = env.scan(regex).first
            # replace based on regex and specific value in the password object
            env = replaceStringBasedOnRegex(env, regex, password["#{key}"])
            env_string = "#{env_string}-e #{env} "
        end
        command = "docker create --name=#{container['name']} -h #{container['name']}.#{domain_name} -m #{container['container_params']['memory']} --memory-swap=#{container['container_params']['memory_swap']} -i -t -u devadmin #{port_string} -v /dev/containers/certs:/devcerts -v /dev/containers/#{container['name']}:/devext -v /backup/containers/#{container['name']}:/backup #{env_string} --net dev-net --log-opt max-size=2m --net-alias=#{container['name']}.#{domain_name} #{container['container_params']['image']['name']}:#{container['container_params']['image']['tag']}"
        return command
    end

    # replace string placeholder based on unique value and regex pattern
    def replaceStringBasedOnRegex( input, regex, value )
        input = input.gsub(regex, value)
        return input
    end
end