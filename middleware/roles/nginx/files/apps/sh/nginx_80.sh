#!/bin/sh

. /apps/sh/apps_env.sh
APP_SVR=/apps/svr
APP_CONF=/apps/conf
PORT=80
pidfile=/apps/run/nginx_80/nginx.pid

DAEMON="$APP_SVR/nginx_${PORT}/sbin/nginx"
PROG="$(basename $DAEMON)"
NGINX_CONF_FILE="$APP_CONF/nginx_${PORT}/nginx.conf"
#LOCKFILE="$APP_RUN/nginx_${PORT}"

start() {
  ulimit -c 1024000
  killall -9 $PROG;
  $DAEMON
  echo "Nginx started!"
}

stop() {
  killall -9 $PROG
  rm -f $pidfile
  echo "Nginx killed!"
}

status() {
  if [ -f $pidfile ];then
  echo "Nginx is running !"
  else
  echo "Nginx is not running !"
  fi
}

reload() {
  killall -HUP $PROG
}

configtest() {
  $DAEMON -t -c $NGINX_CONF_FILE
}


# See how we were called.
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  reload)
    reload
    ;;
  configtest)
    configtest
    ;;
  *)
    echo $"usage: $0 start|stop|status|restart|reload|configtest"
    exit 1
esac

