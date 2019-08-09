FROM golang:alpine as builder

ENV GO111MODULE=on


# Install git
RUN apk update && apk add git

COPY . $GOPATH/src/mypackage/myapp/
RUN rm $GOPATH/src/mypackage/myapp/store.go
WORKDIR $GOPATH/src/mypackage/myapp/


#get dependancies
#you can also use dep
RUN go get -d -v

#build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/bin/store

# STEP 2 build a small image
# start from scratch
FROM scratch

# Copy our static executable
COPY --from=builder /go/bin/store /go/bin/store
#EXPOSE 9080
CMD ["/go/bin/store"]