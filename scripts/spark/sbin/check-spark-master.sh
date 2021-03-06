#!/usr/bin/env bash

SPARK_LOG_PATH="/data/spark/logs"
LIVY_LOG_PATH="/data/livy/logs"

ret_val=0

sk_pid=`ps ax | grep 'spark.*Master' | grep -v grep | awk '{print $1}'`
if [ "x$sk_pid" = "x" ]; then
    echo "Spark master is not running!"
    ret_val=$[$ret_val + 1]
fi

livy_pid=`ps ax | grep 'LivyServer' | grep -v grep | awk '{print $1}'`
if [ "x$livy_pid" = "x" ]; then
    echo "LivyServer is not running!"
    ret_val=$[$ret_val + 2]
fi

HM=`date -d "now" +%H%M`
if [ $HM -eq "0200" ];then
    find $SPARK_LOG_PATH -type f -mtime +7 -name "spark-root-*" -delete
    find $LIVY_LOG_PATH -type f -mtime +7 -name "livy-root-*" -delete
fi

exit $ret_val
