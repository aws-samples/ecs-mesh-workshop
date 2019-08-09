FROM golang:1.9 as binary

COPY . $GOPATH/src/mypackage/myapp/
WORKDIR $GOPATH/src/mypackage/myapp/

# get dependencies
RUN go get -v
# build binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/bin/spot_term_watcher .


FROM alpine:3.6 as alpine
RUN apk add -U --no-cache ca-certificates

FROM scratch
WORKDIR /
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=binary /go/bin/spot_term_watcher /go/bin/spot_term_watcher
ENTRYPOINT ["/go/bin/spot_term_watcher"]