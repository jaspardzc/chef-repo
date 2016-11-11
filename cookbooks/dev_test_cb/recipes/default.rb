#
# Cookbook Name:: dev_test_cb
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

chef_data_bag 'test_bag' do
    ignore_failure false
    action :create
end
