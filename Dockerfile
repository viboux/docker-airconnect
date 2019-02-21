FROM debian:stretch-slim
RUN apt-get update && apt-get -y install wget
RUN wget https://raw.githubusercontent.com/philippe44/AirConnect/master/bin/aircast-x86-64 \
  && chmod +x aircast-x86-64 && mv aircast-x86-64 /bin
RUN wget http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb \
  && dpkg -i ./libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb
ENTRYPOINT ["/bin/aircast-x86-64", "-Z", "-k"]
