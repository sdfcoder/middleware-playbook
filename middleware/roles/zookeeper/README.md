@20200324 by wanzhirui
function for deploy zookeeper from ansible-playbook. This role should place under role directory like: /opt/deploy/roles/zookeeper/

1.config zookeeper cluster first ipaddress and cluster id is necessary. other default variable is in defaults/main.yml. you can modify also.
[root@autodeploy01 /opt/deploy] #cat host.zookeeper
[zookeeper]
10.154.2.94 id=1
10.154.2.95 id=2
10.154.5.89 id=3
2.run playbook  under deploy directory
[root@autodeploy01 /opt/deploy] #ansible-playbook -i host.zookeeper playbooks/zookeeper.yml 
