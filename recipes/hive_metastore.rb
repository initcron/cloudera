#
# Cookbook Name:: cloudera
# Recipe:: hive_metastore
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

include_recipe "cloudera::repo"

package "hive-metastore"

include_recipe "database"
include_recipe "database::mysql"

node.normal['hive']['mysql']['pass'] = secure_password
mysql_connection_info = {:host => "localhost", :username => "root", :password => node['mysql']['server_root_password']}

hive_site_vars = { :options => node[:hive][:hive_site_options] }
hive_site_vars[:options]['javax.jdo.option.ConnectionPassword'] = "#{node.hive.mysql.pass}"

mysql_database "#{node.hive.mysql.dbname}" do
  connection mysql_connection_info
  action :create
  notifies :create, "mysql_database_user[#{node.hive.mysql.user}]", :immediately
  notifies :grant, "mysql_database_user[#{node.hive.mysql.user}]", :immediately
  notifies :run, "execute[hive_populate_schema]", :immediately
end

execute "hive_populate_schema" do
  command "/usr/bin/mysql -u root #{node.hive.mysql.dbname} -p#{node.mysql.server_root_password} < /usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.9.0.mysql.sql"
  action :nothing
end

#mysql_database_user "#{node.hive.mysql.user}" do
#  connection mysql_connection_info
#  password "#{node.hive.mysql.pass}"
#  database_name "#{node.hive.mysql.dbname}"
##  host '%'
##  privileges [:select,:update,:insert,:create,:drop,:delete]
#  action :nothing
#end

mysql_database_user "#{node.hive.mysql.user}" do
  connection mysql_connection_info
  password "#{node.hive.mysql.pass}"
  action :nothing
end

template "/etc/init.d/hive-metastore" do
  source "hadoop_hive_metastore.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :java_home => node[:java][:java_home]
  )
end

service "hive-metastore" do
  action [ :start, :enable ]
end
