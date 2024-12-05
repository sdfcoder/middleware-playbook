# Ansible role: redis

This role is for install standard redis instance.

# Requirements

system-init.

# Role variables

默认安装参数详见: `defaults/main.yml`.
redis_version: 3.0.1     #redis版本，默认3.0.1
redis_mode: standalone   #redis模式，默认为单机版
redis_port: 6379  #redis端口号，默认为6379
aof_switch: 'on'  #aof选项，默认为开
rdb_switch: 'on'  #持久化选项，默认为开
host_memory: '0'  #最大内存设置项，默认为关
set_password: 'yes'  #是否配置密码选项，默认为配置


## Mandatory variables

安装时需要从inventory文件中传入的参数:
redis_password: redis初始密码
redis_mode: redis部署模式，单机版为：standalone

# Dependencies
system-init

# Example Playbook

```
---
- hosts: all
  gather_facts: false
  roles:
    - role: redis
      when: redis_mode == 'standalone'
```

# Example Inventory

```
192.168.182.42 redis_password=qwe123 redis_mode=standalone
192.168.182.43 redis_password=qwe123 redis_mode=standalone
```

# Contribution


# License

Apache

# Author Information
Evan @ gmcc
liuchao-139@139.com
