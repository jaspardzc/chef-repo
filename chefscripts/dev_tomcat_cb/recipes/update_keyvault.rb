####################################################################################
# Cookbook Name: dev_tomcat_cb
# Recipe:: update_keyvault
# Strategy: remove the old keyvault folder and generate new keyvault folder
#           iteratively for all available tomcat containers
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# import available tomcat container list from node attributes
tomcat = node['tomcat']['available']

# local variable
keystore_path = ""
common_keyvault_cmd = ""

# Read Keyvault Secret Key Path
secret_key_path_keyvault = node['keyvault']['secret_key_path']
secret_key_path_mongo = node['mongo']['secret_key_path']

# import mogno keyvault from keyvault data bag
mongo_keyvault = data_bag_item("keyvault_bag", "mongo_keyvault", IO.read(secret_key_path_keyvault))

java_path = mongo_keyvault['java_path']
jar_path = mongo_keyvault['jar_path']

keystore_init_method = mongo_keyvault['keystore_init_method']
keystore_set_method = mongo_keyvault['keystore_set_method']
keystore_get_method = mongo_keyvault['keystore_get_method']
keystore_pwd = mongo_keyvault['keystore_pwd']

# import admin credential from mongo data bag
admin_credential = data_bag_item("mongo_bag", "admin_credential", IO.read(secret_key_path_mongo))

mongo_name = admin_credential['dbname']
mongo_user = admin_credential['dbuser']
mongo_pwd = admin_credential['dbpwd']

# import available tomcat container list
tomcat = node['tomcat']['available']
tomcat.each do |container| 
    # container_name
    container_name = container['container_name']
    # keystore path for each container
    keystore_path = "/dev/containers/#{container_name}/softwares/TranZformKeyvault"
    # shared keyvault command string for initKeyStore, setKeyStore, getKeyStore
    common_keyvault_cmd = "#{keystore_path} #{keystore_pwd} #{keystore_path} #{keystore_pwd} #{keystore_path} #{keystore_pwd}"

    if container['keyvault_update'] == true
        # delete the old keyvault directory and create empty directory
        directory "#{keystore_path}" do
            owner 'devadmin'
            group 'devadmin'
            mode  '0755'
            recursive true
            action [ :delete, :create ]
        end

        # initialize the keyvault when creating the container
        execute 'keyvault_init' do
            group 'devadmin'
            command "#{java_path} -cp #{jar_path} #{keystore_init_method} #{common_keyvault_cmd} #{container_name}"
            action :run
        end

        # set the keyvault 
        execute 'keyvault_set' do
            group 'devadmin'
            command "#{java_path} -cp #{jar_path} #{keystore_set_method} #{common_keyvault_cmd} #{container_name} #{mongo_name}.#{mongo_user} #{mongo_pwd}"
            action :run
        end

        # get the keyvault data from store and print it in the console
        execute 'keyvault_get' do
            group 'devadmin'
            command "#{java_path} -cp #{jar_path} #{keystore_get_method} #{common_keyvault_cmd} #{container_name} #{mongo_name}.#{mongo_user}"
            action :run 
        end
    end
end