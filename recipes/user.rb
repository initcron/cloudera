


user "hdfs" do
  comment "HDFS User"
  home "/home/hdfs"
  shell "/bin/bash"
end

user "user1" do
  comment "Hadoop User 1"
  home "/home/user1"
  shell "/bin/bash"
end

user "user2" do
  comment "Hadoop User 2"
  home "/home/user2"
  shell "/bin/bash"
end

user "user3" do
  comment "Hadoop User 3"
  home "/home/user3"
  shell "/bin/bash"
end

user "user4" do
  comment "Hadoop User 4"
  home "/home/user4"
  shell "/bin/bash"
end

user "user5" do
  comment "Hadoop User 5"
  home "/home/user5"
  shell "/bin/bash"
end

user "hbase" do
  comment "Hbase User"
  home "/home/hbase"
  shell "/bin/bash"
end

group "hbase" do
  members ['hbase']
end

group "hdfs" do
  members ['hdfs', 'hbase', 'user1', 'user2', 'user3', 'user4', 'user5']
end

