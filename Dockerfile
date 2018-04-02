FROM alpine:3.5

MAINTAINER Eben Olson <eben.olson@gmail.com>

RUN 	mkdir -p src && \
	cd src && \
	apk add --update build-base git openssl-dev c-ares-dev util-linux-dev libwebsockets-dev && \
	git clone https://github.com/ebenolson/mosquitto.git && \
	cd mosquitto && \
	sed -i.bak s/WITH_WEBSOCKETS:=no/WITH_WEBSOCKETS:=yes/g config.mk && \
	sed -i.bak s/WITH_DOCS:=yes/WITH_DOCS:=no/g config.mk && \
	make && \
	find . -type f | grep Makefile | xargs grep -r -- --strip-program  | awk {'print $1'} | cut -d : -f 1 | xargs sed -i 's/--strip-program=\${CROSS_COMPILE}\${STRIP}//g' && \
	sed -i 's/set -e; for d in ${DOCDIRS}; do $(MAKE) -C $${d} install; done//g' Makefile  && \
	make install && \
	adduser -s /bin/false -D -H mosquitto && \
	cd / && \
	rm -rf src && \
	rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log
RUN chown -R mosquitto:mosquitto /mosquitto

EXPOSE 1883 9001

ADD docker-entrypoint.sh /usr/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/usr/local/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]
