#!/bin/sh
A=`grep "^*.info;" /etc/rsyslog.conf|grep -v local2|awk '{print $1}'`
B=";local2.none"
C=`grep "^*.info;" /etc/rsyslog.conf|grep -v local2|awk '{print $2}'`
D="$A$B  $C"
echo $D
sed -i "/^*.info\;/c$D" /etc/rsyslog.conf
