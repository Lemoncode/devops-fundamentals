## Clean reosurces

Desde el raíz donde se encuentra `Vagrantfile`

Parar las VMs

```bash
$ vagrant halt
```

Borrar las VMs

```bash
$ vagrant destroy
```

Quitar el paquete

```bash
$ vagrant box remove ubuntu/focal64
```

Eliminar la VM de Virtual Box

```bash
$ VBoxManage unregistervm --delete registry
$ VBoxManage unregistervm --delete jenkins
```