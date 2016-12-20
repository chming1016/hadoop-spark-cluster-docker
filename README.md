#Hadoop and Spark Cluster(1 master and 3 slaves)

```
Hadoop v2.7.3
Spark v2.0.2
Docker v1.12.5
```

##Using Docker Containers

###1. docker pull

```
docker pull chming1016/hadoop-spark-cluster
```

###2. create hadoop network

```
docker network create --driver=bridge hadoop
```

###3. start all container

sh start-container.sh
```
#!/bin/bash

# the default node number is 4
N=${1:-4}

# start hadoop master container
echo "start hadoop-master container..."
docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 8088:8088 \
                -p 8080:8080 \
                --name hadoop-master \
                --hostname hadoop-master \
                chming1016/hadoop-spark-cluster /usr/sbin/sshd -D &> /dev/null

# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	echo "start hadoop-slave$i container..."
	docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                chming1016/hadoop-spark-cluster /usr/sbin/sshd -D &> /dev/null
	i=$(( $i + 1 ))
done 
```

###5. start hadoop

```
docker exec -it hadoop-master bash
```

root@hadoop-master:
```
start-all.sh
```

###6. start spark

root@hadoop-master:
```
sh /usr/local/spark/sbin/start-all.sh
```