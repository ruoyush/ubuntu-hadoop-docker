FROM ubuntu:14.04
MAINTAINER <rul29@pitt.edu>
USER root
#ENV master=localhost \
#    slave=localhost 
#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

## upgrade system
RUN apt-get update \
&& apt-get dist-upgrade -y 

# install necessary packages
ADD ssh_config /root/.ssh/config
RUN apt-get -y install software-properties-common python-software-properties ssh rsync  \

# generate key and import it to the authorized file ; setup permission 
&& ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa \
&& touch ~/.ssh/authorized_keys \
&& cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
&& chmod 600 ~/.ssh/authorized_keys \
&& chmod 600 /root/.ssh/config \
&& chown root:root /root/.ssh/config \
#&& sed -i 's/172/#172/g' /etc/hosts \

# install java
&& add-apt-repository -y ppa:webupd8team/java \
&& apt-get update \
&& echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
&& apt-get -y install oracle-java8-installer \

# download hadoop
&& cd /usr/local/ \
&& wget http://www-us.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz \
&& tar -zxf hadoop-2.7.3.tar.gz \
&& ln -s hadoop-2.7.3 hadoop \
&& cd hadoop \
&& mkdir input \
&& cp etc/hadoop/*.xml input \
&& mkdir -p /hdfs/namenode \
&& mkdir -p /hdfs/datanode

# setup environment for hadoop
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $PATH:$JAVA_HOME/bin 
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR ${HADOOP_HOME}/etc/hadoop
ENV HADOOP_MAPRED_HOME ${HADOOP_HOME}
ENV HADOOP_COMMON_HOME ${HADOOP_HOME}
ENV HADOOP_HDFS_HOME ${HADOOP_HOME}
ENV YARN_HOME ${HADOOP_HOME}
ENV HADOOP_COMMON_LIB_NATIVE_DIR ${HADOOP_HOME}/lib/native
ENV PATH $PATH:$HADOOP_HOME/bin
ENV PATH $PATH:$HADOOP_HOME/sbin
ENV HADOOP_OPTS "-Djava.library.path=$HADOOP_INSTALL/lib"

# replace necessary files for hadoop configuration
ADD *.xml $HADOOP_PREFIX/etc/hadoop/
ADD hadoop-env.sh $HADOOP_PREFIX/etc/hadoop/
ADD bootstrap.sh /etc/hadoop/

# format hadoop and set permission for the bash script 
RUN $HADOOP_PREFIX/bin/hdfs namenode -format \
&& chown root:root /etc/hadoop/bootstrap.sh \
&& chmod +x /etc/hadoop/bootstrap.sh \
&& chown root:root $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh \
&& chmod +x $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

# create folders for hadoop input
RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root 
RUN service ssh start && $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/sbin/start-dfs.sh && $HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input
CMD ["/etc/hadoop/bootstrap.sh","-d"]

# expose port  
EXPOSE 9000 50070 8088 54311 10020 19888 2122

# clean process



