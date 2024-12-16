FROM alpine AS build
WORKDIR /app
RUN apk add --no-cache \
    build-base \
    automake \
    autoconf \
    git
RUN git clone \
    --branch branchHTTPservMutli \
    --depth 1 \
    https://github.com/oswald-os/trigonometric-function.git \
    .
RUN autoreconf --install
RUN ./configure
RUN make

FROM alpine
COPY --from=build /app/trigFunc /usr/local/bin
ENTRYPOINT ["/usr/local/bin/trigFunc"]
