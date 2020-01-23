FROM golang:1.13.6 AS builder
COPY . /go/src/github.com/michaelsanford/project-b
WORKDIR /go/src/github.com/michaelsanford/project-b
RUN go get && CGO_ENABLED=0 GOOS=linux go build -o hacks .

FROM scratch AS app
COPY --from=builder /go/src/github.com/michaelsanford/project-b /opt/conu/
WORKDIR /opt/conu/
EXPOSE 8081
ENTRYPOINT [ "./hacks" ]