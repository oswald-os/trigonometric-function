FROM alpine
WORKDIR /home/trigFunc
COPY ./trigFunc .
RUN apk add libstdc++
RUN apk add libc6-compat
ENTRYPOINT ["./trigFunc"]
