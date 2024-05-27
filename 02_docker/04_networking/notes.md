## Networking

> NOTA: En macOS y Windows podemos usar [Docker for Mac](https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389)

```bash
ifconfig
```

```bash
docker0   
  Link encap:Ethernet  direcciónHW 02:42:3d:a8:f9:51  
  Direc. inet:172.17.0.1  Difus.:0.0.0.0  Másc:255.255.0.0
  Dirección inet6: fe80::42:3dff:fea8:f951/64 Alcance:Enlace
  ACTIVO DIFUSIÓN FUNCIONANDO MULTICAST  MTU:1500  Métrica:1
  Paquetes RX:91 errores:0 perdidos:0 overruns:0 frame:0
  Paquetes TX:143 errores:0 perdidos:0 overruns:0 carrier:0
  colisiones:0 long.colaTX:0 
  Bytes RX:5888 (5.8 KB)  TX bytes:949926 (949.9 KB)
```

```bash
docker network ls
```

```
NETWORK ID          NAME                DRIVER              SCOPE
b2ecc5e33156        bridge              bridge              local
c03a10652aad        daemon_network      bridge              local
9176dc84c12a        host                host                local
b4d1a5fa0f19        none                null                local
```

### Bridge

Este el network driver por defecto

```bash
docker run -d -p 8080:8080 --net=bridge --name myapp myapp
```

```
docker network inspect bridge
```

```
[
    {
        "Name": "bridge",
        "Id": "b2ecc5e33156fe73873a1f77f94b6c1c2213a193ca40a57d55f2a93cf6ccbabb",
        "Created": "2020-06-05T11:43:27.61250571Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "2076e1611d10b34ff4d0de16f5b8ab101f237fbeb2ca015997a0c1a4c6ba3a01": {
                "Name": "myapp",
                "EndpointID": "b845141210996588a223171ea7410b0cea7091b47ed28ce9718ec058fb2023d1",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]
```

### Host

```bash
docker run -d --network=host --name myapp myapp
```

```
docker network inspect host
```

No existe aislamineto desde un punto de vista de la red. Los puertos expuestos están directamente enlazados al `host`.

### None

No existe interfaz de red.

```bash
docker network inspect none
```

[Demo load balancer host](04_networking/00_load_balancer_host)

### User-Defined Networks

Siempre podemos crear nuestras propias redes.

```bash
docker network create --driver=bridge \
--subnet=172.100.1.0/24 --gateway=172.100.1.1 \
--ip-range=172.100.1.2/25 mybridge
```

```bash
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
b2ecc5e33156        bridge              bridge              local
c03a10652aad        daemon_network      bridge              local
9176dc84c12a        host                host                local
bc3de4a5c836        mybridge            bridge              local
b4d1a5fa0f19        none                null                local
```

```bash
docker network inspect mybridge
[
    {
        "Name": "mybridge",
        "Id": "bc3de4a5c836c2628ce88e62f93118fa1903ef93af6ae42df20b124ee353c1ec",
        "Created": "2020-06-07T17:14:25.9972015Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.100.1.0/24",
                    "IPRange": "172.100.1.2/25",
                    "Gateway": "172.100.1.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

[Demo load balancer user defined network](04_networking/01_load_balancer_user_defined_network)

## References

- [Explore networking features](https://docs.docker.com/desktop/networking/)
- [Host Networking](https://docs.docker.com/desktop/networking/)
- [Docker for Mac](https://gist.github.com/BretFisher/5e1a0c7bcca4c735e716abf62afad389)
