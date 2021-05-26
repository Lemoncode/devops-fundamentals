# Docker VM

En Windows dependiendo de nuestro escenario puede ser complicado usar Docker de una manera sencilla y cómoda, como alternativa podemos utilizar Vagrant.

Para levantar nuestra máquina con Vagrant:

```bash
$ cd docker-vm
$ vagrant up
```

Una vez levantada la máquina, podemos acceder mediante:

```bash
$ vagrant ssh
```

Y comprobar que `Docker` está instalado ejecutado `docker -v`

## Cleanup

```bash
$ vagrant halt
$ vagrant destroy
```
