#!/usr/bin/bash
set -x
exec > /var/log/user-data.log 2>&1

# ECS cluster configuration
mkdir -p /etc/ecs
echo "ECS_CLUSTER=${cluster_name}" > /etc/ecs/ecs.config
echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"awslogs\",\"json-file\",\"syslog\"]" >> /etc/ecs/ecs.config

# Optional: create directories for your app
mkdir -p /opt/gateway/properties /opt/gateway/certs
chmod 755 /opt/gateway/properties /opt/gateway/certs
