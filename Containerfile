FROM alpine:3.19 AS build
RUN apk add \
	clang \
	make \
	;

ADD . /pop

RUN make -C /pop CC='clang -static'

RUN mkdir -p /mnt/mail

#FROM fedora:latest as smtp
#RUN dnf -y update && dnf -y install libselinux-utils && dnf clean all
FROM scratch as pop
COPY --from=build /mnt/mail /mnt/mail
VOLUME /mnt/mail
COPY --from=TCP_SERVER_CONTAINER /usr/local/bin/tcp_server /usr/local/bin/tcp_server
COPY --from=build /pop/pop3 /usr/local/bin/pop3

EXPOSE 995
ENTRYPOINT ["/usr/local/bin/tcp_server", "-p", "995", "/usr/local/bin/pop3", "pop3", "/mnt/mail"]
