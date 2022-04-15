FROM golang:1.17 AS build
WORKDIR /go/src/github.com/zyin/sidecar-lifecycle-controller
COPY . /go/src/github.com/zyin/sidecar-lifecycle-controller


RUN apt-get update && apt-get install -y ca-certificates openssl

ARG cert_location=/usr/local/share/ca-certificates

# Get certificate from "github.com"
RUN openssl s_client -showcerts -connect github.com:443 </dev/null 2>/dev/null|openssl x509 -outform PEM > ${cert_location}/github.crt
# Get certificate from "proxy.golang.org"
RUN openssl s_client -showcerts -connect proxy.golang.org:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >  ${cert_location}/proxy.golang.crt
# Update certificates
RUN update-ca-certificates
#RUN go get -v
#RUN mkdir /usr/local/share/ca-certificates/cacert.org
#RUN wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt
#RUN update-ca-certificates
#RUN git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt
#RUN git config --global http.sslverify false
#RUN go env -w GOPROXY=direct GOINSECURE=proxy.golang.org,github.com,gopkg.in,go.googlesource.com,k8s.io,sigs.k8s.io,google.golang.org,golang.org,cloud.google.com,go.opencensus.io,honnef.co,rsc.io,dmitri.shuralyov.com

RUN GO111MODULE="on" CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -a -installsuffix cgo -o main .

RUN apt-get update && apt-get install -y upx
RUN upx main

RUN mkdir -p /empty

FROM scratch
COPY --from=build /go/src/github.com/zyin/sidecar-lifecycle-controller/main /
COPY --from=build /empty /tmp
CMD ["/main"]

