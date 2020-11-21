FROM alpine:3.12 as builder

ARG ZT_COMMIT=167645ba6da857dc11ac430b716a5fff8711a6c9

RUN apk add --update alpine-sdk linux-headers \
  && git clone https://github.com/zerotier/ZeroTierOne.git /src \
  && git -C src reset --hard ${ZT_COMMIT} \
  && cd /src \
  && make -f make-linux.mk

FROM alpine:3.12
LABEL version="1.6.0"
LABEL description="ZeroTier One Docker-only Linux hosts"

RUN apk add --update --no-cache libc6-compat libstdc++

EXPOSE 9993/udp

COPY --from=builder /src/zerotier-one /usr/sbin/
RUN mkdir -p /var/lib/zerotier-one \
  && ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-idtool \
  && ln -s /usr/sbin/zerotier-one /usr/sbin/zerotier-cli

ENTRYPOINT ["zerotier-one"]
