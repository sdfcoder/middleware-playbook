#!/bin/sh


contact='root@localhost'
notify() {
  mailsubject="`hostname` to be $1: $2 floating"
  mailbody="`date '+%F %H:%M:%S'`: vrrp transition, `hostname` changed to be $1"
  echo $mailbody | mail -s "$mailsubject" $contact
}
case "$1" in
  master)
    notify master $2
    su - apps -c "/apps/sh/tomcat_$2.sh start"
    exit 0
  ;;
  backup)
    notify backup $2
    su - apps -c "/apps/sh/tomcat_$2.sh stop"
    exit 0
  ;;
  fault)
    notify fault $2
    /apps/sh/keepalived.sh stop
    exit 0
  ;;
  *)
    echo 'Usage: `basename $0` {master|backup|fault}'
    exit 1
  ;;
esac
