FROM golang:1.13.6 AS builder
WORKDIR /go/src/github.com/michaelsanford/project-b
COPY . .
RUN go get && \
    CGO_ENABLED=0 GOOS=linux go build -o hacks .

FROM scratch AS app
WORKDIR /opt/conu/
COPY --from=builder /go/src/github.com/michaelsanford/project-b .
EXPOSE 8081
ENTRYPOINT [ "./hacks" ]