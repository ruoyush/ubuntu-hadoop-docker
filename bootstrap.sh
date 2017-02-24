#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid


export HADOOP_PREFIX=/usr/local/hadoop
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export HADOOP_MAPRED_HOME=${HADOOP_HOME}
export HADOOP_COMMON_HOME=${HADOOP_HOME}
export HADOOP_HDFS_HOME=${HADOOP_HOME}
export YARN_HOME=${HADOOP_HOME}
export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_HOME}/lib/native

export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_INSTALL/lib"
export JAVA_HOME="/usr/lib/jvm/java-8-oracle"


service ssh start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

#if [[ $1 == "-d" ]]; then
#  while true; do sleep 60; done
#fi

#if [[ $1 == "-bash" ]]; then
/bin/bash
#fi