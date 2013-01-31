#
# Cookbook Name:: tk-apache2
# Recipe:: default
#
# Copyright (C) 2013 Bryan W. Berry
# 
# license: apachev2
#

node.override['apache']['binary']  = "/usr/sbin/httpd.worker"
node.override['apache']['default_site_enabled'] = false
node.override['apache']['listen_ports'] = [ "80"]
node.override[:apache][:mod_pagespeed][:stats_visibility] = "all"

%w{ proxy proxy_balancer proxy_connect proxy_http rewrite }.each do |mod|
  node['apache']['default_modules'] << mod unless node['apache']['default_modules'].include?(mod)
end

%w{ apache2 apache2::mod_pagespeed }.each {|r| include_recipe r }

# hacks the httpd cookbook which should do this
file "/etc/sysconfig/httpd" do
  content <<-EOF
  HTTPD=/usr/sbin/httpd.worker
  EOF
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources( :service => "apache2")
end

web_app "proxy_hello" do
  template "proxy_hello.conf.erb"
  load_balancers node[:tk_apache2][:load_balancers]
end
