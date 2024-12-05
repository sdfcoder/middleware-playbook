#!/bin/bash

if [ ! -f /apps/run/haproxy/haproxy.pid ] ; then
#       /apps/sh/keepalived.sh stop
       exit 1
else
       exit 0
fi
