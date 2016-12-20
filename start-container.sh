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
                chming1016/hadoop-saprk-cluster /usr/sbin/sshd -D &> /dev/null

# start hadoop slave container
i=1
while [ $i -lt $N ]
do
        echo "start hadoop-slave$i container..."
        docker run -itd \
                        --net=hadoop \
                        --name hadoop-slave$i \
                        --hostname hadoop-slave$i \
                        chming1016/hadoop-saprk-cluster /usr/sbin/sshd -D &> /dev/null
        i=$(( $i + 1 ))
done