FROM lsiobase/alpine:3.12 as builder
# ARIANG_VER
ARG BHV=1.1.8
# download bilbili-helper
RUN apk add --no-cache unzip \
&& wget -P /tmp https://github.com/JunzhouLiu/BILIBILI-HELPER/releases/download/V${BHV}/BILIBILI-HELPER-v${BHV}.zip \
&& unzip /tmp/BILIBILI-HELPER-v${BHV}.zip -d /tmp \
&& mv /tmp/BILIBILI-HELPER-v${BHV}.jar /tmp/BILIBILI-HELPER.jar

# bilbili-helper
FROM openjdk:8-jdk-slim-buster
# set label
LABEL maintainer="NG6"
ARG S6_VER=2.0.0.1
ENV TZ=Asia/Shanghai CUSP=true DEDEUSERID=1 SESSDATA=2 BILI_JCT=3 \
    PUID=1026 PGID=100
# copy files
COPY root/ /
COPY --from=builder /tmp/BILIBILI-HELPER.jar  /bilbili-helper/BILIBILI-HELPER.jar
# create abc user
RUN apt -y update && apt -y install wget tzdata \
&&  if [ "$(uname -m)" = "x86_64" ];then s6_arch=amd64;elif [ "$(uname -m)" = "aarch64" ];then s6_arch=aarch64;elif [ "$(uname -m)" = "armv7l" ];then s6_arch=arm; fi  \
&&  wget --no-check-certificate https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.gz  \
&&  tar -xvzf s6-overlay-${s6_arch}.tar.gz  \
&&  rm s6-overlay-${s6_arch}.tar.gz \
&&  chmod a+x /bilbili-helper/BILIBILI-HELPER.jar \
&&  useradd -u 1000 -U -d /config -s /bin/false abc \
&&  usermod -G users abc  \
&&  echo "**** cleanup ****" \
&&  apt-get clean \
&&  rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# volume
VOLUME [ "/bilbili-helper" ]

ENTRYPOINT [ "/init" ]