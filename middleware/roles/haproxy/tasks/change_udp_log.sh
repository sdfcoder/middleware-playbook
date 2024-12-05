#!/bin/sh

line1=$(cat /etc/rsyslog.conf | grep -iE '.*UDP.*514' -B 1 | awk 'NR==1')
line2=$(cat /etc/rsyslog.conf | grep -iE '.*UDP.*514' -B 1 | awk 'NR==2')

if [ ${line1:0:1} = '#' ]
then
    sed -i "s/$line1/${line1:1}/g" /etc/rsyslog.conf
else
    echo "success"
fi

if [ ${line2:0:1} = '#' ]
then
    sed -i "s/$line2/${line2:1}/g" /etc/rsyslog.conf
else
    echo "success"
fi

