FROM redis:5.0

RUN apt-get update && \
	apt-get install -y iputils-ping

COPY start_redis.sh /tmp/start_redis.sh

RUN chmod +x /tmp/start_redis.sh

CMD [ "/tmp/start_redis.sh" ]

