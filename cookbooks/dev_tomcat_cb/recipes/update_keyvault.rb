# recipe keyvault update
# tomcat cookbook

# check if keyvault update is required 
# if required, stop the container if container is running
# remove the old key vault fodler first
# generate new key vault folder
# throw exception if the recipe flow aborted with error

# Manage dependencies
require_relative '../../dev_docker_cb/libraries/docker_service'

# Read Container name from Node attribute
container_name = node['tomcat']['container']['name']

# Read Keyvault Secret Key Path
secret_key_path_keyvault = node['keyvault']['secret_key_path']
secret_key_path_mongo = node['mongo']['secret_key_path']

# Read mogno keyvault from encrypted data bag item
mongo_keyvault = data_bag_item("keyvault_bag", "mongo_keyvault", IO.read(secret_key_path_keyvault))

java_path = mongo_keyvault['java_path']
jar_path = mongo_keyvault['jar_path']

keystore_path = mongo_keyvault['keystore_path']
keystore_init_method = mongo_keyvault['keystore_init_method']
keystore_set_method = mongo_keyvault['keystore_set_method']
keystore_get_method = mongo_keyvault['keystore_get_method']
keystore_pwd = mongo_keyvault['keystore_pwd']

# shared keyvault command string for initKeyStore, setKeyStore, getKeyStore
common_keyvault_cmd = "#{keystore_path} #{keystore_pwd} #{keystore_path} #{keystore_pwd} #{keystore_path} #{keystore_pwd}"

# Read admin credential from encrypted data bag item
admin_credential = data_bag_item("mongo_bag", "admin_credential", IO.read(secret_key_path_mongo))

mongo_name = admin_credential['dbname']
mongo_user = admin_credential['dbuser']
mongo_pwd = admin_credential['dbpwd']

# create an docker service object 
ds = DockerService.new

# fire the following resources if the keyvault is outdated, how to detect automatically?

# delete the old keyvault directory and create empty directory
directory '/dev/containers/lcl-cnt-svc-001/softwares/TranZformKeyvault' do
    owner 'admin'
    group 'admin'
    mode  '0755'
    recursive true
    action [ :delete, :create ]
end

# initialize the keyvault when creating the container
execute 'keyvault_init' do
    group 'admin'
    command "#{java_path} -cp #{jar_path} #{keystore_init_method} #{common_keyvault_cmd} #{container_name}"
    action :run
end

# set the keyvault 
execute 'keyvault_set' do
    group 'admin'
    command "#{java_path} -cp #{jar_path} #{keystore_set_method} #{common_keyvault_cmd} #{container_name} #{mongo_name}.#{mongo_user} #{mongo_pwd}"
    action :run
end


# get the keyvault data from store and print it in the console
execute 'keyvault_get' do
    group 'admin'
    command "#{java_path} -cp #{jar_path} #{keystore_get_method} #{common_keyvault_cmd} #{container_name} #{mongo_name}.#{mongo_user}"
    action :run 
end


