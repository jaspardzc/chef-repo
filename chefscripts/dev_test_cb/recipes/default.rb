####################################################################################
# Cookbook Name: dev_test_cb
# Recipe:: default
# Strategy: testing arbitrary resources
# Copyright (c) 2016 The Auhtors, All Rights Reserved
# Last Updated: 11/19/2016
# Author: kevin.zeng
#####################################################################################

Chef::Log.info("this is dev_test_cb default recipe")
chef_data_bag 'test_bag' do
    ignore_failure false
    action :create
end
