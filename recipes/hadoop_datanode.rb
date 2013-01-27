#
# Cookbook Name:: cloudera
# Recipe:: hadoop_datanode
#
# Author:: Cliff Erson (<cerson@me.com>)
# Author:: Istvan Szukacs (<istvan.szukacs@gmail.com>)
# Copyright 2012, Riot Games
#
# Significant modifications by Tim Ellis Oct 2012
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
  # use default CDH4 init script
  package "hadoop-hdfs-datanode"
elsif node[:hadoop][:release] == '3u3'
  package "hadoop-#{node[:hadoop][:version]}-datanode"

  template "/etc/init.d/hadoop-0.20-datanode" do
    mode 0755
    owner "root"
    group "root"
    variables(
      :java_home => node[:java][:java_home]
    )
  end
end

#Example hue-plugins-1.2.0.0+114.20-1.noarch 
package "hue-plugins" do
  # if you need a particular version of hue, uncomment this and define the vars
  #version "#{node[:hadoop][:hue_plugin_version]}-#{node[:hadoop][:hue_plugin_release]}"
  action :install
end

if node[:hadoop][:release] == '3u3'
  node[:cdh3][:hdfs_site]['dfs.data.dir'].split(',').each do |dir|
    directory dir do
      mode 0755
      owner "hdfs"
      group "hdfs"
      action :create
      recursive true
    end
    directory "#{dir}/lost+found" do
      owner "hdfs"
      group "hdfs"
    end
  end
elsif node[:hadoop][:release] == '4'
  node[:cdh4][:hdfs_site]['dfs.data.dir'].split(',').each do |dir|
    directory dir do
      mode 0755
      owner "hdfs"
      group "hdfs"
      action :create
      recursive true
    end
    directory "#{dir}/lost+found" do
      owner "hdfs"
      group "hdfs"
    end
  end
end


if node[:hadoop][:release] == '3u3'
  service "hadoop-#{node[:hadoop][:version]}-datanode" do
    action [ :start, :enable ]
    supports :status => true
  end
elsif node[:hadoop][:release] == '4'
  service "hadoop-hdfs-datanode" do
    action [ :start, :enable ]
    supports :status => true
    subscribes :restart, resources(:template => "/etc/hadoop/#{node[:hadoop][:conf_dir]}/core-site.xml")
    subscribes :restart, resources(:template => "/etc/hadoop/#{node[:hadoop][:conf_dir]}/hdfs-site.xml")
  end
end
