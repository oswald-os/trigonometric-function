FROM alpine AS build
WORKDIR /app
RUN apk add --no-cache \
    build-base \
    automake \
    autoconf
COPY . .
RUN ./configure
RUN make

FROM alpine
COPY --from=build /app/trigFunc /usr/local/bin
ENTRYPOINT ["/usr/local/bin/trigFunc"]
