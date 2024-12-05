@20200326 by wangtao
这是部署自动部署kafka集群的playbook程序，部署前提是需要安装jdk和zookeeper，将配置目录等写入roles/kafka/defaults/main.yml中，这个文件的其他参数可以按需修改

1.host配置样例，写入部署的ip，kafka的broke id，zookeeper集群信息
[root@cmh-k8s01 ~/components-2020v1.8]#  cat host.kafka 
[kafka]
10.154.6.135 id=1 zookeeper_nodes=10.154.6.135:2181,10.154.6.141:2181,10.154.6.15:2181

2.运行palybook
[root@autodeploy01 /opt/deploy] #ansible-playbook -i inventory/host.kafka playbooks/kafka.yml 
