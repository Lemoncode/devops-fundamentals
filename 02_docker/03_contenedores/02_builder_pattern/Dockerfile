FROM golang:latest AS builder

WORKDIR /app

COPY . .

RUN CG0_ENABLED=0 GOOS=linux go build .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app .

EXPOSE 8080

ENTRYPOINT [ "./app" ]