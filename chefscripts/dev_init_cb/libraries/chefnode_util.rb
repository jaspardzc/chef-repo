####################################################################################
# Cookbook Name: dev_init_cb
# Library:: chefnode_util
# Methods: isExternalCertificateChanged
#          isInternalCertificateChanged
#          getNodeContainerName
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

    # check if external certificate is changed
    def isExternalCertificateChanged ( currentState, toBeState ) 
        if (defined?currentState['containers']["#{toBeState['name']}"])
            if (currentState['containers']["#{toBeState['name']}"]['external_certs_status'] == "received") &&
               (toBeState['requires_external_certs'] == true) 
                return true
            end
        end
    end

    # check if internal certificate is changed
    def isInternalCertificateChanged ( currentState, toBeState ) 
        if (defined?currentState['containers']["#{toBeState['name']}"])
            if (currentState['containers']["#{toBeState['name']}"]['internal_certs_status'] == "received") &&
               (toBeState['requires_internal_certs'] == true)
                return true
            end
        end
    end
    
    # util method for converting containerList to a simple containerSet
    # and the containerSet only contains container's name
    def getNodeContainerName ( containerList )
        # linting the cntainer list to container set
        containerSet = Set.new()
        containerList.each do |container|
            containerSet.add?(container['name'])
        end
        return containerSet
    end
end