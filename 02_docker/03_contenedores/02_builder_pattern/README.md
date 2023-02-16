## Builder Pattern

Para demostrar como funciona este patrón vamos a usar _Go_

Crear _main.go_

```go
package main

import "fmt"
import "net/http"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Are you trying to visit %s ?", r.URL.Path)
	})

	http.ListenAndServe(":8080", nil)
}
```

Crear Dockerfile

```Dockerfile
FROM golang:latest

WORKDIR /app

COPY . .

RUN CG0_ENABLED=0 GOOS=linux go build .

EXPOSE 8080

ENTRYPOINT [ "./app" ]
```

Ahora podemos construir la imagen y ejecutar un nuevo contenedor

```bash
docker build -t mygoapp .
```

```bash
docker run -p 8080:8080 mygoapp
google localhost:8080/other/and/787
```

Si comprobamos el pesoo de la imagen:

```
REPOSITORY                                      TAG                 IMAGE ID            CREATED             SIZE
mygoapp                                         latest              b3ff89eb79bc        36 seconds ago      817MB
```

Vamos a refactorizar para reducir el tamaño de la imagen:

```Dockerfile
FROM golang:latest AS builder

WORKDIR /app

COPY . .

RUN CG0_ENABLED=0 GOOS=linux go build .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app .

EXPOSE 8080

ENTRYPOINT [ "./app" ]
```

> NOTA: Es posible tener problemas con la imagen base de Alpine, para evitarlos utilizar `ubuntu:20.04`.

Si volvemos a construir la imagen:

```bash
docker build -t mygoapp .
```

```bash
docker run -p 8080:8080 mygoapp
```

If we check the size of our image

```
REPOSITORY                                      TAG                 IMAGE ID            CREATED              SIZE
mygoapp                                         latest              5fc8a56092aa        12 seconds ago       13MB
```

```Dockerfile
FROM golang:latest 

WORKDIR /app

COPY . .

RUN go env -w GO111MODULE=off

RUN CG0_ENABLED=0 GOOS=linux go build .

EXPOSE 8080

ENTRYPOINT ["./app"]
```
