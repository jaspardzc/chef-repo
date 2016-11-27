###################################################################################
# Cookbook Name: dev_mongodb_cb
# Recipe:: config_container
# Strategy: 
# - config the mongodb container iteratively
# - For each created mongo containers, open the container interative prompt shell
# - Open the mongo shell inside the container, Execute the CreateUsers.sh script
#   to create multiple users for each every mongo databases
# - Execute the CreateCollections.sh script to loading all collections data for
#   each every mongo databsases
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/27/2016
# Author: kevin.zeng
#####################################################################################

# import dependencies
require 'docker'

# import available mongodb container list from node attributes
mongodb = node['mongodb']['available']

# config the containers iteratively
mongodb.each do |container|
  # open the container iteractive shell
  # open mongo shell inside container
  # execute CreateUsers.sh script to create multiple users 
  # execute CreateCollections.sh script to load all collections data
  # exit container iteractive shell
  execute "config mongodb container: #{container['container_name']}" do
    group 'devadmin'
    command "docker exec -it #{container['container_name']} /dev/softwares/mongodb-linux-x86_64-debian71-3.2.8/bin/mongo 127.0.0.1:27017/admin -u sysadmin -p sysadmin --ssl --sslPEMKeyFile /devext/softwares/mongodb-a/certs/certificate.pem --sslCAFile /devext/softwares/mongodb-a/certs/certificate.pem --sslPEMKeyPassword changeit --sslAllowInvalidHostnames --sslAllowInvalidCertificates\
        && /devext/backup/ScriptAutomation/Scripts/CreateUsers.sh\
        && /devext/backup/ScriptAutomation/Scripts/CreateCollections.sh\
        && exit"
    action :run
  end
end

