# middleware deployment
## 简介
本项目旨在提供移动云通用标准组件的部署安装功能。使用ansible剧本完成各个组件的推送安装和初始化设置。


## 说明
** 1. 对前期进行剧本开发、承担组件部署维护的南方基地/SRE同事表示感谢 **
** 2. 组件安装包打包在 middleware-teg-YYMM.tar.gz
** 3. 安装前需具备ansible环境（移动云各节点默认自带）；完成系统初始化（push_init脚本）
** 4. 使用apps用户进行统一部署推送，部署节点apps具备sudo权限 （推送/etc/sudoer.d/black_white）文件权限640所属root
** 5. 编译后的组件均打包存放在 middleware-teg-MMDD/roles/sharestorage/apps/svr/目录下）#md5值#
** 6. 建议重置程序文件用户、组及权限 ** 
cd middleware-teg-YYMM/roles/sharestorage/apps/
chown -R apps:apps ./svr
chmod -R 775 ./svr


## 版本说明
** keepalive-1.2.16 **
** haproxy-1.7.12 **
** jdk-1.8.0_172 **
** zookeeper-3.4.14 **
** kafka-2.11-1.1.1 **
** memcache-1.5.12 **
** nginx-1.18.0 **
** erlang/otp-22.3 **
** rabbitmq-3.8.2 **
** tomcat-7.0.105 **
** activemq-5.15.3 **
** redis-5.0.5 **
** vsftp **


##启停说明
旨在全使用apps用户通过/apps/sh组件启停脚本进行启停操作
su - apps
或者在root下/bin/su - apps -c '具体命令来执行'


## 安装步骤
apps用户下
tar -xvzf middleware-teg-MMDD.tar.gz
cd middleware-teg-MMDD/


##
** 如需单独初始化 **
ansible-playbook -i inventory/hosts playbooks/init.yml


##su - apps
** Haproxy组件安装 **
部署
ansible-playbook -i inventory/hosts.haproxy playbooks/haproxy.yml
启停
sudo /apps/sh/haproxy.sh (start|stop)
配置检查
sudo /apps/sh/haproxy.sh check
进程重载
sudo /apps/sh/haproxy.sh reload
进程检查
ps -ef|grep haproxy (10个进程)
端口检查
10000端口


##su - apps
** Keepalive组件安装 **
部署
ansible-playbook -i inventory/hosts.keepalived playbooks/keepalived.yml
启停
sudo /apps/sh/keepalived.sh (start|stop)
进程检查
sudo ps -ef|grep keepalive 
需要配合LVS/IPVS负载
/apps/conf/keepalived/keepalived配置文件中去掉-P并重启生效


##su - apps
** JDK环境安装 **
部署
ansible-playbook -i inventory/hosts.jdk playbooks/jdk.yml
版本检查 （su -到对应用户下）
java -version
预期
java version "1.8.0_172"
Java(TM) SE Runtime Environment (build 1.8.0_172-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.172-b11, mixed mode)


##su - apps
** Zookeeper组件安装 **
ansible-playbook -i inventory/hosts.zookeeper playbooks/zookeeper.yml
启停
/apps/sh/zookeeper.sh (start|stop)
进程检查
ps -ef|grep zookeeper (一个进程)
端口检查
2181端口
9999端口
集群状态检查
各节点执行/apps/svr/zookeeper_2181/bin/zkServer.sh status
（一个leader，两个follower）


##su - apps
** Kafka组件安装 **
前置条件：完成zookeeper安装
ansible-playbook -i inventory/hosts.kafka playbooks/kafka.yml
启停
/apps/sh/kafka.sh (start|stop|status|clean)
进程检查
ps -ef|grep kafka (一个进程)
端口检查
9092端口
9988端口


##su - apps
** Memcached组件安装 **
ansible-playbook -i inventory/hosts.memcached playbooks/memcached.yml
启停
/apps/sh/memcached.sh (start|stop)  ##默认启停脚本中-c 65535 -m 20480 （适用于物理服务器）
进程检查
ps -ef|grep memcache (一个进程)
端口检查
11211端口
节点复用时
可在/apps/sh/memcached.sh中-m 20480 -c 65535后加上 -l 节点管理网地址，重启生效


##su - apps
** Nginx组件安装 **
ansible-playbook -i inventory/hosts.nginx playbooks/nginx.yml
启停
sudo /apps/sh/nginx_80.sh (start|stop)
进程检查
sudo ps -ef|grep nginx
端口检查
80端口


##su - apps
** Erlang环境安装 **
ansible-playbook -i inventory/hosts.erlang playbooks/erlang.yml
版本检查 （su -到对应用户下）
erl -version
预期
Erlang (SMP,ASYNC_THREADS,HIPE) (BEAM) emulator version 10.7


##su - apps
** Rabbitmq组件安装 ** 
前置：集群模式需先配置好节点/etc/hosts或使用DNS
单机 ansible-playbook -i inventory/hosts.rabbitmq playbooks/rabbitmq.yml
集群 ansible-playbook -i inventory/hosts.rabbitmq_cluster playbooks/rabbitmq_cluster.yml
启停
/apps/sh/rabbitmq.sh (start|stop)
检查集群状态rabbitmqctl cluster_status
检查节点状态rabbitmqctl status
进程检查
ps -ef|grep rabbitmq
端口检查
5672端口
15672端口
范例配置
添加MQ用户 rabbitmqctl add_user mcf PasSworD123@
设置管理员标签 rabbitmqctl set_user_tags mcf administrator
设置用户权限 rabbitmqctl set_permissions -p / mcf "." "." ".*"
设置镜像队列策略 rabbitmqctl set_policy ha-all '^(?!amq\.).*' '{"ha-mode": "all"}'


##su - apps
** Tomcat组件安装 **
ansible-playbook -i inventory/hosts.tomcat playbooks/tomcat.yml
启停
/apps/sh/tomcat_8080.sh (start|stop)
进程检查
ps -ef|grep tomcat
端口检查
8080端口


##su - apps
** Activemq组件安装 ** (单活)
前置：完成数据库安装/数据库VIP配置/MQ数据库及用户创建授权
范例：登入数据库，执行：
create database activemq_mcf;
GRANT ALL PRIVILEGES ON activemq_mcf.* TO 'mcf'@'localhost' IDENTIFIED BY '1qaz_EDC@WSX3edc';
GRANT ALL PRIVILEGES ON activemq_mcf.* TO 'mcf'@'10.142.%' IDENTIFIED BY '1qaz_EDC@WSX3edc';
集群 ansible-playbook -i inventory/hosts.activemq_cluster playbooks/activemq_cluster.yml
启停
/apps/sh/activemq.sh (start|stop)
进程检查
ps -ef|grep activemq (进程集群三个节点都有)
端口检查（单活）
8161端口
61616端口
5672端口


##su - apps
** Redis组件安装 **
模式：单机、主从、哨兵、集群
前置：主从模式需要预先规划并部署Keepalive组件

单机：
ansible-playbook -i inventory/hosts.redis_standalone playbooks/redis.yml
启停：
/apps/sh/redis_6379.sh (start|stop|restart|status)
进程检查
ps -ef|grep redis (一个进程)
端口检查
6379端口
服务检查
/apps/svr/redis_6379/src/redis-cli -a '<password>' PING（返回PONG）

哨兵：
ansible-playbook -i inventory/hosts.redis_sentinel playbooks/redis_sentinel.yml
进程检查
ps -ef|grep redis (两个进程)
端口检查
6379端口
26379端口
服务检查
三节点分别执行 /apps/svr/redis_6379/src/redis-cli -a '<password>' PING（返回PONG）
三节点分别节点执行/apps/svr/redis_6379/src/redis-admin info replication
启停：
/apps/sh/redis_6379.sh (start|stop|restart|status)
注：当sentinel进程意外丢失,执行如下命令手动拉起
/apps/svr/redis_6379/src/redis-sentinel /apps/conf/redis_6379/sentinel.conf

主备：
ansible-playbook -i inventory/hosts.redis_standby playbooks/redis_standby.yml
进程检查
ps -ef|grep redis (一个进程)
端口检查
6379端口
服务检查
节点分别执行 /apps/svr/redis_6379/src/redis-cli -a '<password>' PING（返回PONG）
节点分别节点执行/apps/svr/redis_6379/src/redis-admin info replication
VIP检查
主备切换 telnet 虚IP 6379

集群：
前提（root用户下）：sysctl vm.overcommit_memory=1 && echo vm.overcommit_memory=1 >> /etc/sysctl.conf
echo never > /sys/kernel/mm/transparent_hugepage/enabled && echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
sysctl net.core.somaxconn=2048 && echo "net.core.somaxconn=2048" >> /etc/sysctl.conf
部署（apps用户下） 
ansible-playbook -i inventory/hosts.redis_cluster playbooks/redis_cluster.yml
进程检查
ps -ef|grep redis (两个进程)
端口检查
6379端口
6380端口
16379端口
16380端口
服务检查
/apps/svr/redis_6379/src/redis-admin cluster info
/apps/svr/redis_6379/src/redis-admin cluster nodes


##su - apps
** ftp组件安装 ** （OP使用需要）
ansible-playbook -i inventory/hosts.ftp playbooks/vsftp.yml
端口检查
21端口


##
附录
1、haproxy负载bc-mysql(配置仅供参考)
listen rdb_mysql
        bind 10.142.71.136:3306
        balance leastconn
        mode tcp
        option tcpka
        option tcplog
        option clitcpka
        option srvtcpka
        timeout client 28801s
        timeout server 28801s
        timeout connect 28801s
        server mysql1 10.142.71.133:3306 check inter 2000 rise 2 fall 3
        server mysql2 10.142.71.134:3306 backup check inter 2000 rise 2 fall 3
        server mysql3 10.142.71.135:3306 backup check inter 2000 rise 2 fall 3


2、keepalive为以下组件提供高可用时,检查脚本(端口、进程、状态)
 2.1、与haproxy: script "< /dev/tcp/127.0.0.1/10000" 
 2.2、与nginx: script "< /dev/tcp/127.0.0.1/80"
 2.3、与ftp: script "< /dev/tcp/127.0.0.1/21"
 2.4、与redis:
     script "/apps/sh/keepalived_scripts/redis_check.sh #ip01# 6379" 配合
     notify_master "/apps/sh/keepalived_scripts/redis_master.sh 127.0.0.1 #ip02# 6379"
     notify_backup "/apps/sh/keepalived_scripts/redis_backup.sh 127.0.0.1 #ip02# 6379"
     notify_fault "/apps/sh/keepalived_scripts/redis_fault.sh"
     notify_stop "/apps/sh/keepalived_scripts/redis_stop.sh"
     该部分脚本推送主备redis时会自动修改
 2.5、其余需要keepalive组件的业务子系统，需补全keepalive healthchk所需的业务检查脚本
注：上述检查端口的方法只试用于TCP服务端口


3、系统参数优化 /etc/sysctl.conf（sysctl -p生效）
 3.1、当keepalive和haproxy共用，添加
      net.ipv4.ip_nonlocal_bind = 1
 3.2、部署haproxy, 添加
      net.ipv4.ip_local_port_range = 1025 65534
 3.3、部署activemq，添加
      net.core.somaxconn = 65535
      net.ipv4.tcp_syncookies = 1
      net.ipv4.tcp_tw_reuse = 1
      net.ipv4.tcp_timestamps = 1
      net.ipv4.tcp_fin_timeout = 20
      vm.swappiness = 1
      net.core.rmem_max = 67108864
      net.core.wmem_max = 67108864
      net.core.rmem_default = 67108864
      net.core.wmem_default = 67108864
      net.ipv4.tcp_rmem = 4096 87380 33554432
      net.ipv4.tcp_wmem = 4096 65536 33554432
      net.core.optmem_max = 67108864
      net.core.netdev_max_backlog = 250000
      kernel.shmall = 4294967296
      net.ipv4.conf.all.accept_redirects = 0
      vm.max_map_count = 262144
      kernel.pid_max = 65536
