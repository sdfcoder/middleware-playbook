#!/bin/sh
#

### BEGIN INIT INFO
# Provides:          rabbitmq-server
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Description:       RabbitMQ broker
# Short-Description: Enable AMQP service provided by RabbitMQ broker
### END INIT INFO

# Source function library.
. /apps/sh/apps_env.sh
export HOME=/home/apps/
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/apps/svr/rabbitmq_5672/sbin
NAME=rabbitmq-server

DAEMON=/apps/svr/rabbitmq_5672/sbin/${NAME}
CONTROL=/apps/svr/rabbitmq_5672/sbin/rabbitmqctl
DESC=rabbitmq-server
USER=admin
ROTATE_SUFFIX=
INIT_LOG_DIR=/apps/svr/rabbitmq_5672/logs
PID_FILE=/apps/svr/rabbitmq_5672/run/rabbitmq-server

START_PROG="daemon"
LOCK_FILE=/apps/svr/rabbitmq_5672/run/$NAME

test -x $DAEMON || exit 0
test -x $CONTROL || exit 0

RETVAL=0
set -e

[ -f /etc/default/${NAME} ] && . /etc/default/${NAME}

start_rabbitmq () {
    status_rabbitmq quiet
    if [ $RETVAL = 0 ] ; then
        echo RabbitMQ is currently running
    else
        RETVAL=0
        set +e
        $DAEMON > "${INIT_LOG_DIR}/startup_log" \
            2> "${INIT_LOG_DIR}/startup_err" \
            0<&- &
        RETVAL=$?
        set -e
        case "$RETVAL" in
            0)
                echo SUCCESS
                if [ -n "$LOCK_FILE" ] ; then
                    touch $LOCK_FILE
                fi
                ;;
            *)
                echo FAILED - check ${INIT_LOG_DIR}/startup_\{log, _err\}
                RETVAL=1
                ;;
        esac
    fi
}

stop_rabbitmq () {
    status_rabbitmq quiet
    if [ $RETVAL = 0 ] ; then
        set +e
        $CONTROL stop > ${INIT_LOG_DIR}/shutdown_log 2> ${INIT_LOG_DIR}/shutdown_err
        RETVAL=$?
        set -e
        if [ $RETVAL = 0 ] ; then
            if [ -n "$LOCK_FILE" ] ; then
                rm -f $LOCK_FILE
            fi
        else
            echo FAILED - check ${INIT_LOG_DIR}/shutdown_log, _err
        fi
    else
        echo "RabbitMQ is not running"
        RETVAL=0
    fi
}

status_rabbitmq() {
    set +e
    if [ "$1" != "quiet" ] ; then
        $CONTROL status 2>&1
    else
        $CONTROL status > /dev/null 2>&1
    fi
    if [ $? != 0 ] ; then
        RETVAL=3
    fi
    set -e
}

cluster_status() {
    set +e
    $CONTROL status > /dev/null 2>&1
    if [ $? != 0 ] ; then
        echo "Rabbitmq Node is not running"
    else
        $CONTROL cluster_status
    fi
    set -e
}

restart_running_rabbitmq () {
    status_rabbitmq quiet
    if [ $RETVAL = 0 ] ; then
        restart_rabbitmq
    else
        echo RabbitMQ is not runnning
        RETVAL=0
    fi
}

restart_rabbitmq() {
    stop_rabbitmq
    start_rabbitmq
}

case "$1" in
    start)
        echo -n "Starting $DESC: "
        start_rabbitmq
        echo "$NAME."
        ;;
    stop)
        echo -n "Stopping $DESC: "
        stop_rabbitmq
        echo "$NAME."
        ;;
    status)
        status_rabbitmq
        ;;
    reload|restart)
        echo -n "Restarting $DESC: "
        restart_rabbitmq
        echo "$NAME."
        ;;
    cluster_status)
        cluster_status
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart|reload}" >&2
        RETVAL=1
        ;;
esac

exit $RETVAL
