#!/bin/sh

 ##################
#  updated by hyk  #
#    2019-04-26    # 
 ##################

SH_DIR=$(dirname $(which $0))
. $SH_DIR/apps_env.sh

PORT={{http_port}}
umask 002
TOMCAT_HOME=$APP_SVR/tomcat_${PORT}

export TOMCAT_HOME
export CATALINA_BASE=$TOMCAT_HOME
export CATALINA_HOME=$TOMCAT_HOME
export CATALINA_TMPDIR=$TOMCAT_HOME/temp
export CATALINA_PID=$APP_RUN/tomcat_${PORT}/tomcat.pid
export JRE_HOME=$JAVA_HOME
export JAVA_OPTS="$JAVA_OPTS -server -XX:MetaspaceSize={{metaspacesize}} -XX:MaxMetaspaceSize={{maxmetaspacesize}}"
export JAVA_OPTS="$JAVA_OPTS -Xms{{heapsize}} -Xmx{{maxheapsize}}"
export JAVA_OPTS="$JAVA_OPTS -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp/"

{% if is_enabled_jmx == 1 %}
export JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=8999 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=true -Dcom.sun.management.jmxremote.password.file=${CATALINA_HOME}/conf/jmxremote.password -Dcom.sun.management.jmxremote.access.file=${CATALINA_HOME}/conf/jmxremote.access" 
{% endif %}

export JAVA_OPTS="$JAVA_OPTS {{add_java_opts}}"

if [ ! "$USER" = "apps" ]; then
    echo "please run by apps";
    exit 0;
fi

#if [ -f $SH_DIR/.tomcat_opt.sh ]
#then
#    source $SH_DIR/.tomcat_opt.sh
#fi

ulimit -s 20480

processexist(){
   
   num=`ps -ef |grep -v grep |grep tomcat|grep java| grep $PORT|wc -l`
   if [[ $num == 1 ]]
   then
       echo  1
   elif [[ $num == 0 ]]
   then
       echo  0
   else
       echo "too many tomcat process;please check!"
       exit 127
   fi

}

pidisexist(){ 
   if [ -f $CATALINA_PID ] 
   then
       echo 1
   else
       echo 0
   fi
}

value(){
  pidstatus=`pidisexist`
  psstatus=`processexist`
  if [[ "$psstatus" == "0" ]]
  then
      if [[ "$pidstatus" == "0" ]]
      then
          echo "00"
      elif [[ "$pidstatus" == "1" ]]
      then
          echo "01"
      fi
  elif [[ "$psstatus" == "1" ]]
  then
      if [[ "$pidstatus" == "0" ]]
      then
          echo "10"
      elif [[ "$pidstatus" == "1" ]]
      then
          echo "11"
      fi
  else
      echo $psstatus
  fi
}

status(){
  value=`value`
  if [[ "$value" == "00" ]]
  then
      echo "TOMCAT stop"
  elif [[ "$value" == "01"  ]]
  then
      echo "TOMCAT stop BUT PID FILE EXIST"
  elif [[ "$value" == "10"  ]] 
  then 
       echo "TOMCAT is running BUT PID FILE NOT EXIST" 
  elif [[ "$value" == "11"  ]]
  then
       pidfile=`cat $CATALINA_PID`
       pidproc=`ps -ef|grep -v grep |grep tomcat|grep java|grep $PORT|awk '{print $2}'`
       if [[ "$pidfile" == "$pidproc" ]]
       then 
           echo "TOMCAT is running"
       else
           echo "TOMCAT is running BUT PROCESS PID NOT MATCH THE PID IN FILE"
       fi
  else
      echo "$value"
  fi
}


start(){
  value=`value`
  if [[ "$value" == "00" ]]
  then
      echo "TOMCAT ALREADY STOP"
      echo "NOW START TOMCAT"
      $APP_SVR/tomcat_${PORT}/bin/startup.sh
      sleep 5
      value=`value`
      if [[ "$value" == "10"  ]] || [[ "$value" == "11"  ]]
      then
          echo "TOMCAT START SUCCESS"
      elif [[ "$value" == "00" ]] || [[ "$value" == "01"  ]]
      then
          echo "TOMCAT START FAIL;PLEASE CHECK THE LOG：/apps/logs/tomcat_$PORT/catalina.out"
      fi
  elif [[ "$value" == "01"  ]]
  then
      echo "TOMCAT ALREADY STOP BUT PID FILE EXIST"
      echo "NOW REMOVE PID FILE AND START TOMCAT"
      rm -rf $CATALINA_PID
      $APP_SVR/tomcat_${PORT}/bin/startup.sh
      value=`value`
      if [[ "$value" == "10"  ]] || [[ "$value" == "11"  ]]
      then
          echo "TOMCAT START SUCCESS"
      elif [[ "$value" == "00" ]] || [[ "$value" == "01"  ]]
      then
          echo "TOMCAT START FAIL;PLEASE CHECK THE LOG：/apps/logs/tomcat_$PORT/catalina.out"
      fi
  elif [[ "$value" == "10"  ]] || [[ "$value" == "11"  ]]
  then
      echo "TOMCAT ALREADY START"
  fi
}

stop(){
  value=`value`
  start_user=`ps -ef |grep -v grep |grep tomcat|grep java| grep $PORT|awk '{print $1}'`
  process_pid=`ps -ef |grep -v grep |grep tomcat|grep java| grep $PORT|awk '{print $2}'`
  if [[ ! -z $start_user ]] && [[ "$start_user" != "$USER" ]]
  then
       echo "********************************************"
       echo "*WARNING!!!! tomcat is start by $start_user*"
       echo "*you may stop tomcat failed by $USER********"
       echo "********************************************"
  fi
  if [[ "$value" == "00" ]] || [[ "$value" == "01"  ]]
  then
      echo "TOMCAT ALREADY STOP"
  elif [[ "$value" == "10"  ]] || [[ "$value" == "11"  ]]
  then
      echo "NOW STOP TOMCAT"
      kill -9 $process_pid
      rm -rf $CATALINA_PID
      sleep 5
      value=`value`
      if [[ "$value" == "00"  ]]  
      then
          echo "TOMCAT STOP SUCCESS"
      elif [[ "$value" == "10" ]] || [[ "$value" == "11"  ]]
      then
          echo "TOMCAT STOP FAIL;PLEASE CHECK THE LOG：/apps/logs/tomcat_$PORT/catalina.out"
      fi
  fi
}

input=$1


case $input in 
start) 
       start;;
stop)
       stop;;
status)
       status;;
restart)
       stop
       sleep 10
       start;;
*)
       echo "USAGE $0 start|stop|status|restart"
esac
