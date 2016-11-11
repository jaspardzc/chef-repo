
# Cookbook: dev_artifactory_cb

# Recipe: download_latest

# manage required dependencies
require_relative '../libraries/download_manager'

# Read node attributes
ms_snapshot = node['microservice']['snapshot']

# Read Artifactory Secret Key path
secret_key_path = node['artifactory']['secret_key_path']

# Read system credential from encrypted data bag item
artifactory_bag = data_bag("artifactory_bag")
system_credential = data_bag_item("artifactory_bag", "system_credential", IO.read(secret_key_path))

# Instantiate Local Variables
localmeta = DownloadManager.getLocalMeta()
remotemeta = DownloadManager.getRemoteMeta()
remotemeta = system_credential['username'] + ":" + system_credential['password'] + "@" + remotemeta
remoteuri = ""
localuri = ""

# Init Logging Info
Chef::Log.info("Start downloading the artifacts from Jfrog remote artifactory repository.....")

# download metadata to temporary directory for further processing
remote_file "/tmp/#{ms_snapshot}" do
    owner 'admin'
    group 'admin'
    mode '0755'
    source "http://#{remotemeta}"
    action :create
end

# Ruby Block
ruby_block 'set_artifact_latest_version' do
    block do
        # set the latest version of the artifact
        DownloadManager.setLatestVersion(ms_snapshot)

        # concat the remote uri using remotemeta and latest_version
        latest_version = DownloadManager.getLatestVersion()
        remoteuri = remotemeta + latest_version
        localuri = localmeta + latest_version
    end
    action :run
end

# Resource to download the latest artifact 
remote_file "download_latest_artifact" do
	owner 'admin'
    group 'admin'
    mode '0755'
    path lazy { "#{localuri}" }
    source lazy { "http://#{remoteuri}" }
	action :nothing
    subscribes :create, 'ruby_block[set_artifact_latest_version]', :immediately
end

# delete the temporary file
file "/tmp/#{ms_snapshot}" do
    owner 'admin'
    group 'admin'
    mode '0755'
    action :delete
end

# Exit Logging Info
Chef::Log.info("Sucessfully downloaded latest artifactory from Jfrog remote artifactory repository.....")

