set -x
IP=$(ping $IP -c 1 | head -n1 | awk -F\( '{print $2}' | awk -F\) '{print $1}')
ip_args=""
for index in $(seq 0 $((COUNT-1)))
do
	NODE_PORT=$((PORT+index))
	ip_args="$ip_args ${IP}:${NODE_PORT}"

cat <<EOF > "/tmp/redis_${NODE_PORT}.conf"
bind 0.0.0.0
port $NODE_PORT
cluster-announce-ip ${IP}
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
daemonize yes
protected-mode no
pidfile  /var/run/redis_${NODE_PORT}.pid
dir /redis-data/${NODE_PORT}
logfile /var/log/redis/redis_${NODE_PORT}.log
EOF
	mkdir -p /redis-data/${NODE_PORT}
	mkdir -p /var/log/redis/
	redis-server /tmp/redis_${NODE_PORT}.conf
done

echo "yes" | redis-cli --cluster create --cluster-replicas 1 $ip_args

tail -f /var/log/redis/redis*.log
