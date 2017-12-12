#!/bin/bash

DATE=$(date +%s)
ROOT_FOLDER=${rpm.path}

## Copy the latest hdfs-site.xml and hdfs-site-refreshable.xml(when add volume, this file created, 'dfs.datanode.data.dir' property in it) from the Datanode process to a tmp location and grant read permission for hdfs user.
mkdir /tmp/volume-balancer-${DATE}
cp /var/run/cloudera-scm-agent/process/$(ls -1rt /var/run/cloudera-scm-agent/process | grep DATANODE | tail -n 1)/hdfs-site*.xml /tmp/volume-balancer-${DATE}
chmod 755 /tmp/volume-balancer-${DATE}/*

## Run the balancer as hdfs, with classpath hack to include hdfs-site.xml but exclude the log4j.properties provided by cloudera-scm-agent.
sudo -u hdfs HADOOP_USER_CLASSPATH_FIRST=true HADOOP_CLASSPATH=/tmp/volume-balancer-${DATE} hadoop jar ${ROOT_FOLDER}/lib/volume-balancer-${project.version}.jar org.apache.hadoop.hdfs.server.datanode.VolumeBalancerNew $@ | tee -a ${ROOT_FOLDER}/logs/log-$(date +%s).log

