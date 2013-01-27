
#
# Cookbook Name:: cloudera
# Recipe:: zookeeper_server
#
# Author:: Istvan Szukacs (<istvan.szukacs@gmail.com>)
# Copyright 2012, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "zookeeper-server"

directory "#{node[:zookeeper][:data_dir]}" do
  mode 0755
  owner "zookeeper"
  group "zookeeper"
  action :create
  recursive true
end

zk_servers = [node]
zk_servers += search(:node, "role:cloudera_zookeeper AND chef_environment:#{node.chef_environment} NOT name:#{node.name}") 

zk_servers.sort! { |a, b| a.name <=> b.name }

template "/etc/zookeeper/conf/zoo.cfg" do
  source "zoo.cfg.erb"
  mode 0644
  variables(:servers => zk_servers)
end

template "/etc/init.d/hadoop-zookeeper-server" do
  source "hadoop_zookeeper_server.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :java_home => node[:java][:java_home]
  )
end

script "Initialize Zookeeper Server" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  not_if "test -d #{node[:zookeeper][:data_dir]}/version-2"
  code <<-EOH
  service zookeeper-server init
  EOH
end

myid = zk_servers.collect { |n| n[:ipaddress] }.index(node[:ipaddress])

template "#{node[:zookeeper][:data_dir]}/myid" do
  source "myid.erb"
  owner "zookeeper"
  group "zookeeper"
  variables(:myid => myid)
end

service "zookeeper-server" do
  action [ :start, :enable ]
  subscribes :restart, resources(:template => "#{node[:zookeeper][:data_dir]}/myid")
  subscribes :restart, resources(:template => "/etc/zookeeper/conf/zoo.cfg")
end
