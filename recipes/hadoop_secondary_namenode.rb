#
# Cookbook Name:: cloudera
# Recipe:: hadoop_secondary_namenode
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

include_recipe "cloudera"

if node[:hadoop][:release] == '4'
  package "hadoop-hdfs-secondarynamenode"
else
  package "hadoop-#{node[:hadoop][:version]}-secondarynamenode"
end

template "/etc/init.d/hadoop-#{node[:hadoop][:version]}-secondarynamenode" do
  mode 0755
  owner "root"
  group "root"
  variables(
    :java_home => node[:java][:java_home]
  )
end

if node[:hadoop][:release] == '3u3'
  node[:cdh3][:hdfs_site]['fs.checkpoint.dir'].split(',').each do |dir|
    directory dir do
      mode 0755
      owner "hdfs"
      group "hdfs"
      action :create
      recursive true
    end
  end
elsif node[:hadoop][:release] == '4'
  node[:cdh4][:hdfs_site]['fs.checkpoint.dir'].split(',').each do |dir|
    directory dir do
      mode 0755
      owner "hdfs"
      group "hdfs"
      action :create
      recursive true
    end
  end
end

service "hadoop-#{node[:hadoop][:version]}-secondarynamenode" do
  action [ :start, :enable ]
  supports :status => true
end

