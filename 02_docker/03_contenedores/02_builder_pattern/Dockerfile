FROM golang:latest AS builder

WORKDIR /app

COPY . .

# Reference: https://stackoverflow.com/questions/47714278/why-is-compiling-with-cgo-enabled-0-slower
# Reference: https://golang.org/cmd/cgo/
RUN CG0_ENABLED=0 GOOS=linux go build .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app .

EXPOSE 8080

ENTRYPOINT [ "./app" ]
