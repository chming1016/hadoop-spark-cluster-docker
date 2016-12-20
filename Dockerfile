FROM chming1016/ubuntu
MAINTAINER chming1016 <chming1016@gmail.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-8-jdk wget

# install hadoop 2.7.3
RUN wget ftp://ftp.twaren.net/Unix/Web/apache/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz && \
	tar -xzvf hadoop-2.7.3.tar.gz && \
	mv hadoop-2.7.3 /usr/local/hadoop && \
	rm hadoop-2.7.3.tar.gz

# set exportironment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin

# ssh without password
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
	mkdir -p ~/hdfs/datanode && \
	mkdir $HADOOP_HOME/logs 
# config ssh
RUN echo 'Port 2122' >> /etc/ssh/ssh_config && \
	sed -i 's/Port 22/Port 2122/g' /etc/ssh/sshd_config && \
	echo 'Host localhost' > ~/.ssh/config && \
	echo 'StrictHostKeyChecking no' >> ~/.ssh/config && \
	echo 'Host 0.0.0.0' >> ~/.ssh/config && \
	echo 'StrictHostKeyChecking no' >> ~/.ssh/config && \
	echo 'Host hadoop-*' >> ~/.ssh/config && \
	echo 'StrictHostKeyChecking no' >> ~/.ssh/config && \
	echo 'UserKnownHostsFile=/dev/null' >> ~/.ssh/config
# config hadoop-env.sh and core-site.xml	
RUN sed -i 's/${JAVA_HOME}/\/usr\/lib\/jvm\/java-8-openjdk-amd64/g' $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
	sed -i 's/<configuration>//g' $HADOOP_HOME/etc/hadoop/core-site.xml && \
	sed -i 's/<\/configuration>//g' $HADOOP_HOME/etc/hadoop/core-site.xml && \
	echo '<configuration>' >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
	echo '\t<name>fs.default.name</name>' >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
	echo '\t<value>hdfs://hadoop-master:9000</value>' >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/core-site.xml && \
	echo '</configuration>' >> $HADOOP_HOME/etc/hadoop/core-site.xml
# config yarn-site.xml
RUN sed -i 's/<configuration>//g' $HADOOP_HOME/etc/hadoop/yarn-site.xml && \ 
	sed -i 's/<\/configuration>//g' $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '<configuration>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '\t<name>yarn.nodemanager.aux-services</name>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '\t<value>mapreduce_shuffle</value>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    echo '</property>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '\t<name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '\t<value>org.apache.hadoop.mapred.ShuffleHandler</value>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '\t<name>yarn.resourcemanager.hostname</name>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '\t<value>hadoop-master</value>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
	echo '</configuration>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml
# config hdfs-site.xml
RUN sed -i 's/<configuration>//g' $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
	sed -i 's/<\/configuration>//g' $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '<configuration>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '\t<name>dfs.namenode.name.dir</name>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '\t<value>file:///root/hdfs/namenode</value>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '<property>'  >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '\t<name>dfs.datanode.data.dir</name>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '\t<value>file:///root/hdfs/datanode</value>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '\t<name>dfs.replication</name>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '\t<value>3</value>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
	echo '</configuration>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml
# config mapred-site.xml
RUN echo '<configuration>' > $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
	echo '<property>' >> $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
	echo '\t<name>mapreduce.framework.name</name>' >> $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
	echo '\t<value>yarn</value>' >> $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
	echo '</property>' >> $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
	echo '</configuration>' >> $HADOOP_HOME/etc/hadoop/mapred-site.xml
# config slaves
RUN echo 'hadoop-slave1' > $HADOOP_HOME/etc/hadoop/slaves && \
	echo 'hadoop-slave2' >> $HADOOP_HOME/etc/hadoop/slaves && \
	echo 'hadoop-slave3' >> $HADOOP_HOME/etc/hadoop/slaves
# config ~/.bashrc
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc && \
	echo 'export HADOOP_HOME=/usr/local/hadoop' >> ~/.bashrc && \
	echo 'export PATH=$PATH:$HADOOP_HOME/bin' >> ~/.bashrc && \
	echo 'export PATH=$PATH:$HADOOP_HOME/sbin' >> ~/.bashrc && \
	echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc && \
	echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc && \
	echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc && \
	echo 'export YARN_HOME=$HADOOP_HOME' >> ~/.bashrc && \
	echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.bashrc && \
	echo 'export HADOOP_OPTS=" -Djava.library.path=$HADOOP_HOME/lib"' >> ~/.bashrc && \
	echo 'export JAVA_LIBRARY_PATH=$HADOOP_HOME/lib/native:$JAVA_LIBRARY_PATH' >> ~/.bashrc

RUN chmod +x $HADOOP_HOME/sbin/start-all.sh && \
	chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
	chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]