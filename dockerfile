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


# Pull base image
From tomcat:8-jre8

# Maintainer
MAINTAINER "email2satyam88@gmail.com"

ADD makemyplan.jar /usr/local/tomcat/webapps
RUN chown -R makemyplan /usr/local/tomcat/webapps
USER makemyplan
CMD "catalina.sh" "run"
EXPOSE 8080


