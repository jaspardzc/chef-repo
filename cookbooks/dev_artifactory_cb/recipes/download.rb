
# Download Recipe for Artifactory Cookbook

# manage required dependencies
require_relative '../libraries/download_manager'

# Instantiate Local Variables
localuri = DownloadManager.getLocalUri()
remoteuri = DownloadManager.getRemoteUri()

# Read Artifactory Secret Key path
secret_key_path = node['artifactory']['secret_key_path']

# Read system credential from encrypted data bag item
artifactory_bag = data_bag("artifactory_bag")
system_credential = data_bag_item("artifactory_bag", "system_credential", IO.read(secret_key_path))

# Concatnate system credential with the remoteuri
remoteuri = system_credential['username'] + ":" + system_credential['password'] + "@" + remoteuri

puts remoteuri

# Init Logging Info
Chef::Log.info("Start downloading the artifacts from Jfrog remote artifactory repository.....")

# Main Resource for artifact downloading 
remote_file "#{localuri}" do
    owner 'admin'
    group 'admin'
    mode '0755'
    source "http://#{remoteuri}"
	action :create
end

# Exit Logging Info
Chef::Log.info("Sucessfully finished all the artifacts downloading from Jfrog remote artifactory repository.....")







