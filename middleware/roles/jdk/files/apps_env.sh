#!/bin/sh

APP=/apps
APP_CONF=$APP/conf
APP_DATA=$APP/data
APP_LIB=$APP/lib
APP_LOG=$APP/logs
APP_RUN=$APP/run
APP_SH=$APP/sh
APP_SHAREDSTORAGE=$APP/sharedstorage
APP_SVR=$APP/svr
APP_TOOL=$APP/tools

export APP
export APP_LIB
export APP_DATA
export APP_CONF
export APP_LOG
export APP_RUN
export APP_SH
export APP_SHAREDSTORAGE
export APP_SVR
export APP_TOOL

JAVA_HOME=$APP_SVR/jdk8
CLASSPATH=$APP_SVR/jdk8/lib
JAVA_PATH=$JAVA_HOME/bin/
export JAVA_HOME
export CLASSPATH
PATH=$JAVA_PATH:$PATH
export PATH

# LD_LIBRARY_PATH=$APP_LIB/libmcrypt/lib:$APP_LIB/freetype/lib:$APP_LIB/zlib/lib:$APP_LIB/openssl/lib:$APP_LIB/pcre/lib:$APP_LIB/jpeg/lib:$APP_LIB/libpng/lib:$APP_LIB/libgd/lib:/usr/lib:/usr/lib64:$LD_LIBRARY_PATH
# PHP_PATH=$APP_SVR/php/bin/
# export LD_LIBRARY_PATH
# PATH=$PHP_PATH:$PATH
# export PATH

# MYSQL_PATH=$APP_TOOL/percona-xtrabackup-2.2.12/bin/:$APP_SVR/bcrdb/bin/:$APP_SVR/mysql_3306/bin
# PATH=$MYSQL_PATH:$PATH
# export PATH