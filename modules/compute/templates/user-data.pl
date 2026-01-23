#!/usr/bin/bash

set -x
exec > /var/log/user-data.log 2>&1

sudo su

#set up directories the agent uses
sudo mkdir -p /var/log/ecs /etc/ecs /var/lib/ecs/data /var/lib/ecs/volume-plugin /var/lib/ecs/volumes

sudo mkdir -p /sys/fs/cgroup/systemd/ecs

sudo touch /etc/ecs/ecs.config

echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"awslogs\",\"json-file\",\"syslog\"]" >> /etc/ecs/ecs.config
PATH= $PATH:/usr/local/bin

# Set up necessary rules to enable IAM roles for tasks
sudo sysctl -w net.ipv4.conf.all.route_localnet=1
sudo iptables -t nat -A PREROUTING -p tcp -d <IP Value> --dport 80 -j DNAT --to-destination <IP>
sudo iptables -t nat -A OUTPUT -p tcp -d <IP Value> -m tcp --dport 80 -j REDIRECT --to-ports <port>

mkdir -p /opt/gateway/properties
chmod 755 /opt/gateway/properties
mkdir -p /opt/gateway/certs
chmod 755 /opt/gateway/certs

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -b ~/bin/aws
echo $PATH | grep ~/bin
export PATH=~/bin:$PATH

# run the agent
sudo docker run --name ecs-agent \
  --detach=true \
  --restart=on-failure:10 \
  --volume=/var/run/docker.sock:/var/run/docker.sock \
  --volume=/var/log/ecs/:/log/ \
  --volume=/var/lib/ecs/data/:/data \
  --net=host \
  --env-file=/etc/ecs/ecs.config \
  --env ECS_LOGFILE=/log/ecs-agent.log \
  --env ECS_DATADIR=/data/ \
  --env ECS_ENABLE_TASK_IAM_ROLE=true \
  --env ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true \
  amazon/amazon-ecs-agent:latest