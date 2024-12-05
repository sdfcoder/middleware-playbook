#!/bin/bash

program_home=/apps/svr/memcached
program=memcached
#run_user=root

action=${1:start}

function check()
{
	count=`ps -ef | grep $program_home/bin/$program  | grep -v grep | wc -l`

	if test $count -ge 1; then
		return 0;
	fi
	return 1;
}

function get_pids()
{	
	ps -ef | grep $program_home/bin/$program | grep -v 'grep' | awk '{ print $2}' 
}

function status()
{
	if check; then
		pid=`get_pids`
		echo "${program} is ok, pid=$pid"
	else
		echo "${program} is down"
	fi
}

function start()
{
	if check; then
		pid=`get_pids`
		echo "${program} already startup,pid=$pid"
	else
		${program_home}/bin/${program} -d -m 20480 -c 65535 -P /apps/run/memcached/memcached.pid -vv >> /apps/logs/memcached/memcached.log 2>&1 
		sleep 1;
		if check; then
			pid=`get_pids`
			echo "${program} start oK, pid=$pid"
		else
			echo "${program} start failed!"
		fi
	fi
}

function stop()
{
	if check; then
		pid=`get_pids`
		killall -9 ${program}
		sleep 1
		
		if check; then
			echo "${program} stop failed, pid=$pid"
		else
			echo "${program} stop oK, pid=$pid"
		fi
	else
		echo "${program} not startup yet!"
	fi
}

case $action in
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
	*)
		echo "Usage: $0 start/stop/restart/status" 2>&1
		;;
esac

exit 0;
