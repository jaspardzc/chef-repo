####################################################################################
# Cookbook Name: dev_tomcat_cb
# Recipe:: update_ssl
# Strategy: remove the old certs folder for ssl keys
#           fetch update ssl certifications, private key, pem file from environment
#           level data bag
#           create the new certs folder containing ssl keys
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

# Read SSL Secret Key Path
secret_key_path = node['ssl']['secret_key_path']
#secret_key_path = bag_item[node.chef_environment]['ssl']['secret_key_path']

# Read external ssl configuration from encrypted data bag item on env level
ssl_external = data_bag_item("ssl_bag", "ssl_external", IO.read(secret_key_path))

# Read internal ssl configuration from encrypted data bag item on env file
ssl_internal = data_bag_item("ssl_bag", "ssl_internal", IO.read(secret_key_path))

# local variables
certs_external = '/dev/containers/certs/external'
certs_internal = '/dev/containers/certs/internal'

# delete the old ssl external config directory and create empty directory
directory "#{certs_external}" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    recursive true
    action [ :delete, :create ]
end

# delete the old ssl internal config directory and create empty directory
directory "#{certs_internal}" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    recursive true
    action [ :delete, :create ]
end

# fetch the external private key from data bag item
file "#{certs_external}/private.key" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_external['private_key']}"
    action :create
end

# fetch the internal private key from data bag item
file "#{certs_internal}/private.key" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_internal['private_key']}"
    action :create
end

# fetch the external encrypted private key from data bag item
file "#{certs_external}/privateencrypted.key" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_external['private_key_encrypted']}"
    action :create
end

# fetch the internal encrypted private key from data bag item
file "#{certs_internal}/privateencrypted.key" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_internal['private_key_encrypted']}"
    action :create
end

# fetch the external public certificate from data bag item
file "#{certs_external}/public.crt" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_external['public_crt']}"
    action :create
end

# fetch the internal public certificate from data bag item
file "#{certs_internal}/public.crt" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_internal['public_crt']}"
    action :create
end

# fetch the external certificate pem from data bag item
file "#{certs_external}/certificate.pem" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_external['certificate_pem']}"
    action :create
end

# fetch the internal certificate pem from data bag item
file "#{certs_internal}/certificate.pem" do
    owner 'devadmin'
    group 'devadmin'
    mode '0755'
    content "#{ssl_internal['certificate_pem']}"
    action :create
end
