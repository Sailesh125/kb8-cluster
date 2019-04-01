FROM 1234567899.dkr.ecr.eu-central-1.amazonaws.com/base-image-debian:stretch-jre8-1
#Location from where you will download the base Image
MAINTAINER satyam@xyz.com
#DL of your Team who will manage this file
# setup group and user, initialize home
RUN addgroup -gid 30002 satyam-ms && \
	adduser --gid 30002  --system --disabled-login --home /app --shell /sbin/nologin -u 30002 satyam-ms

COPY satyam-ms.jar /app

RUN chown -R satyam-ms /app

EXPOSE 8080

USER satyam-ms

WORKDIR app

ENTRYPOINT exec java $JAVA_OPTS -jar ./satyam-ms.jar
