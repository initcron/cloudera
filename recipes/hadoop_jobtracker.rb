#
# Cookbook Name:: cloudera
# Recipe:: hadoop_jobtracker
#
# Author:: Cliff Erson (<cerson@me.com>)
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
  package "hadoop-#{node[:hadoop][:version]}-mapreduce-jobtracker"
  service "hadoop-#{node[:hadoop][:version]}-mapreduce-jobtracker" do
    action [ :start, :enable ]
    supports :status => true
    subscribes :restart, resources(:template => "/etc/hadoop/#{node[:hadoop][:conf_dir]}/core-site.xml")
    subscribes :restart, resources(:template => "/etc/hadoop/#{node[:hadoop][:conf_dir]}/mapred-site.xml")
  end
elsif node[:hadoop][:release] == '3u3'
  package "hadoop-#{node[:hadoop][:version]}-jobtracker"

  template "/etc/init.d/hadoop-#{node[:hadoop][:version]}-jobtracker" do
    mode 0755
    owner "root"
    group "root"
    source "hadoop-#{node[:hadoop][:version]}-jobtracker.erb"
    variables(
      :java_home => node[:java][:java_home]
    )
  end
  service "hadoop-#{node[:hadoop][:version]}-jobtracker" do
    action [ :start, :enable ]
    supports :status => true
  end
end

