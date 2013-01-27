# Cookbook Name:: cloudera
# Recipe:: hbase_master
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

include_recipe "cloudera"

script "Create hbase dir on hdfs" do
  interpreter "bash"
  user "hdfs"
  cwd "/tmp"
  not_if "hadoop fs -ls /hbase > /dev/null"
  code <<-EOH                                                                                                                                                                                                                                                                                                                  
  hadoop fs -mkdir /hbase                                                                                                                                                                                                                                                                                                      
  hadoop fs -chown hbase:hdfs /hbase                                                                                                                                                                                                                                                                                           
  EOH
end

if node[:hadoop][:release] == '4'
  package "hbase-master"

  service "hbase-master" do
    action [ :start, :enable ]
    supports :status => true
  end
elsif node[:hadoop][:release] == '3u3'
  package "hadoop-hbase-master"

  template "/etc/init.d/hadoop-hbase-master" do
    source "hadoop_hbase_master.erb"
    mode 0755
    owner "root"
    group "root"
    variables(
      :java_home => node[:java][:java_home]
    )
  end
  
  template "/usr/lib/hbase/bin/hbase-daemon.sh" do
    source "hbase_daemon.erb"
    mode 0755
    owner "root"
    group "root"
    variables(
      :java_home => node[:java][:java_home]  
    )
  end
  
  template "/usr/lib/hbase/bin/hbase-config.sh" do
    source "hbase_config.erb"
    mode 0755
    owner "root"
    group "root"
    variables(
      :java_home => node[:java][:java_home]  
    )
  end

  service "hadoop-hbase-master" do
    action [ :start, :enable ]
    supports :status => true
    subscribes :restart, resources(:template => "/etc/hadoop/#{node[:hbase][:conf_dir]}/hbase-env.sh")
    subscribes :restart, resources(:template => "/etc/hadoop/#{node[:hbase][:conf_dir]}/hbase-site.xml")
  end
end

