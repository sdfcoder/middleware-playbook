# Ansible role: redis

This role is for install redis server in cluster mode

# Requirements

role: redis.

# Role variables

默认配置详见: `defaults/main.yml`.
```
redis_mode: cluster  #redis部署模式，集群模式
redis_port: 6379     #redis默认端口
master_port: 6379    #默认主端口
slave_port: 6380     #默认备端口
redis_version: 3.0.1 #redis版本
aof_switch: 'on'     #aof开关
rdb_switch: 'on'     #持久化开关
host_memory: '0'     #max memory设置开关
set_password: 'yes'  #是否设置密码开关
```

## Mandatory variables
cluster_role=creator  #集群创建节点，安装ruby和gem环境，执行创建集群脚本
cluster_members='["192.168.182.42","192.168.182.43","192.168.182.44"]'   #集群成员列表

# Dependencies
None.

# Example Playbook

```
---
- hosts: all
  gather_facts: false
  roles:
    - { name: redis, redis_port: "6379", set_password: 'no', when: redis_mode == 'cluster'}
    - { name: redis, redis_port: "6380", set_password: 'no', when: redis_mode == 'cluster'}

    - role: redis_cluster
      when: redis_mode == 'cluster'
```

# Example Inventory

```
192.168.182.42 redis_password=qwe123 redis_mode=cluster cluster_role=creator  cluster_members='["192.168.182.42","192.168.182.43","192.168.182.44"]' 
192.168.182.43 redis_password=qwe123 redis_mode=cluster cluster_role=member
192.168.182.44 redis_password=qwe123 redis_mode=cluster cluster_role=member
```


# Contribution


# License

Apache

# Author Information
Evan @ gmcc
liuchao-139@139.com
