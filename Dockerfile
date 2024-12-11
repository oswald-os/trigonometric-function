FROM alpine
WORKDIR /home/trigFunc
COPY ./trigFunc /usr/local/bin
RUN apk add libstdc++
RUN apk add libc6-compat
ENTRYPOINT ["/usr/local/bin/trigFunc"]
