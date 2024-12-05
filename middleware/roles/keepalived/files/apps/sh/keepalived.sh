#!/bin/sh

SH_DIR=$(dirname $(which $0))
. $SH_DIR/apps_env.sh

# Startup script for the Keepalived daemon
#
# processname: keepalived
# pidfile: $APP_RUN/keepalived/keepalived.pid
# config: $APP_CONF/keepalived/keepalived.conf
# chkconfig: - 21 79
# description: Start and stop Keepalived

# Source function library
. /etc/rc.d/init.d/functions

# Source configuration file (we set KEEPALIVED_OPTIONS there)
. $APP_CONF/keepalived/keepalived

RETVAL=0
KEEPALIVED="$APP_SVR/keepalived/sbin/keepalived"

prog="keepalived"

start() {
    echo -n $"Starting $prog: "
    daemon ${KEEPALIVED}  ${KEEPALIVED_OPTIONS}
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && touch $APP_RUN/keepalived/$prog
}

stop() {
    echo -n $"Stopping $prog: "
    if [ -f $APP_RUN/keepalived/$prog ]; then
        kill $(cat $APP_RUN/keepalived/$prog.pid)
        echo "          [ ok ]" && rm -f $APP_RUN/keepalived/$prog
    else
        echo "          [ Failed ]"
    fi
}

reload() {
    echo -n $"Reloading $prog: "
    killproc keepalived -1
    RETVAL=$?
    echo
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        stop
        start
        ;;
    condrestart)
        if [ -f $APP_RUN/keepalived/$prog ]; then
            stop
            start
        fi
        ;;
    status)
        status $prog
        RETVAL=$?
        ;;
    *)
        echo "Usage: $0 {start|stop|reload|restart|condrestart|status}"
        RETVAL=1
esac

exit $RETVAL