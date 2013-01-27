#
# Cookbook Name:: cloudera
# Recipe:: oozie_server
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

package "oozie"
package "unzip"

#oozie_site_vars = { :options => node[:hadoop][:oozie_site] }

#template "/etc/oozie/oozie-site.xml" do
#  source "generic-site.xml.erb"
#  mode 0755
#  owner "root"
#  group "root"
#  action :create
#  variables oozie_site_vars
#end

#template "/usr/lib/oozie/bin/oozied.sh" do
#  source "oozied.sh.erb"
#  mode 0755
#  owner "root"
#  group "root"
#  action :create
#end

unless File.exists?("/etc/oozie/oozieServerIsConfigured.chefFlag") 
  remote_file "/tmp/ext-2.2.zip" do
    owner "oozie"
    mode  0644
    source "http://extjs.com/deploy/ext-2.2.zip"
  end
  
#  remote_file "/tmp/mysql-connector-java-5.1.21.jar" do
#    source "http://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar"
#  end
  
#  execute "sudo -u oozie /usr/lib/oozie/bin/oozie-setup.sh -jars /tmp/mysql-connector-java-5.1.21.jar -extjs /tmp/ext-2.2.zip"
  execute "sudo -u oozie unzip /tmp/ext-2.2.zip -d /var/lib/oozie/"
  execute "sudo touch /etc/oozie/oozieServerIsConfigured.chefFlag"
end

script "Create Oozie DB Schema" do
  interpreter "bash"
  not_if "test -f /etc/oozie/oozieSchemaCreated.chefFlag"
  user "root"
  cwd "/tmp"
  code <<-EOH                                                                                                                                
  sudo -u oozie /usr/lib/oozie/bin/ooziedb.sh create -run
  touch /etc/oozie/oozieSchemaCreated.chefFlag
  EOH
end

script "Install Oozie Sharelib" do
  interpreter "bash"
  not_if "hadoop fs -ls /user/oozie/share > /dev/null"
  user "hdfs"
  cwd "/tmp"
  code <<-EOH
  hadoop fs -mkdir /user/oozie
  mkdir /tmp/ooziesharelib
  cd /tmp/ooziesharelib
  tar xzf /usr/lib/oozie/oozie-sharelib.tar.gz
  hadoop fs -put share /user/oozie/share
  hadoop fs -chown oozie:oozie /user/oozie
  EOH
end

service "oozie" do
  action [ :start, :enable ]
end
