#!/usr/bin/env bash


CONF_FILE="${FLINK_HOME}/conf/flink-conf.yaml"

d=$(cat $CONF_FILE | grep jobmanager.archive.expiration-time | sed s/[[:space:]]//g | awk -F: '{print $2}')
hd=$(cat $CONF_FILE | grep historyserver.web.tmpdir | sed s/[[:space:]]//g | awk -F: '{print $2}')
hd="$hd"jobs/
jd=$(cat $CONF_FILE | grep jobmanager.archive.fs.dir | awk -F: '{print $3}' | cut -c 3-)

t=$(date -d -${d}day +"%Y-%m-%d %H:%M:%S")

for file in `ls -l --time-style=full-iso $hd | awk '{if ($6" "$7 < "'"$t"'") {print $9}}'`
do
  rm -rf $hd$file
done

t=$(date -d -${jet}day +"%Y-%m-%d %H:%M:%S")
for file in `hadoop fs -ls $jd | awk '{if ($6" "$7 < "'"$t"'") {print $8}}'`
do
  hadoop fs -rm -r $file
done