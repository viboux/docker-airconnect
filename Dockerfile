FROM debian:stretch-slim
RUN wget http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb \
  && dpkg -o ./libssl1.0.0_1.0.1t-1+deb8u10_amd64.deb
RUN wget --output-document=/bin/aircast-x86-64 https://raw.githubusercontent.com/philippe44/AirConnect/master/bin/aircast-x86-64 && chmod +x /bin/aircast-x86-64
ENTRYPOINT ["/bin/aircast-x86-64", "-Z", "-k"]
