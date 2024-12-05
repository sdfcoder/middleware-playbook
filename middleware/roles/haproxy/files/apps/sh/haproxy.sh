#!/bin/sh

SH_DIR=$(dirname $(which $0))
. $SH_DIR/apps_env.sh

# chkconfig: - 85 15
# description: HA-Proxy is a TCP/HTTP reverse proxy which is particularly suited \
#              for high availability environments.
# processname: haproxy
# config: $APP_SVR/haproxy/haproxy.cfg
# pidfile: $APP_RUN/haproxy/haproxy.pid
# author: leannmak

prog="haproxy"

DAEMON=$APP_SVR/$prog/sbin/$prog
CONFIG=$APP_CONF/$prog/$prog.cfg
PIDFILE=$APP_RUN/$prog/$prog.pid
LOCKFILE=$APP_RUN/$prog/$prog.sock
PID=`cat $PIDFILE`

test -x $DAEMON || exit 0

RETVAL=0

start() {
  echo -n "Starting $prog: "
  $DAEMON -D -f $CONFIG -p $PIDFILE
  RETVAL=$?
  if [ "$RETVAL" == "0" ] ; then
      echo "            [OK]"
      touch $LOCKFILE
  else
      echo "            [Failed]"
  fi
  return $RETVAL
}

stop() {
  echo -n "Shutting down $prog: "
#  kill $(cat $PIDFILE)
  killall $prog
  RETVAL=$?
  if [ "$RETVAL" == "0" ] ; then
      echo "            [OK]"
      rm -rf $LOCKFILE
      rm -rf $PIDFILE
  else
      echo "            [Failed]" 
  fi
  return $RETVAL
}

status() {
  if [ ! -f $PIDFILE ] ; then
       echo "$prog is stopped."
  else
       echo "$prog is running."
  fi
}

restart() {
  if [ ! -f $PIDFILE ] ; then
       echo "$prog is stopped."
       start
  else 
       stop
       start
  fi
}

reload() {
  echo -n "Reloading $prog: "
  $DAEMON -D -f $CONFIG -p $PIDFILE -sf $PID
  RETVAL=$?
  if [ "$RETVAL" == "0" ] ; then
      echo "            [OK]"
      touch $LOCKFILE
  else
      echo "            [Failed]"
  fi
  return $RETVAL
}

check() {
  $DAEMON -c -q -V -f $CONFIG
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
    restart
    ;;
  status)
    status
    ;;
  check)
    check
    ;;
  reload)
    reload
    ;;
  *)
    echo $"Usage: $prog {start|stop|restart|status|check|reload}"
    exit 1
esac

exit $?
