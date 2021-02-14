# Acceso al registry desde Jenkins pipeline

Partiendo de dos máquinas virtuales que se encuentran en la misma red, una con Jenkins y otra con registry, el objetivo es ineractuar con el registry desde una pipeline con Jenkins. El `Vagrantfile` es el siguiente:

`./Vagrantfile`

```ruby
Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: $update_system
    config.vm.provision :docker
    config.vm.provision "shell", inline: $hosts_setup
  
    config.vm.define "jenkins" do |jenkins|
      jenkins.vm.box = "ubuntu/focal64"
      jenkins.vm.hostname = "jenkins.intranet"
      jenkins.vm.network "private_network", ip: "172.16.43.100"
      jenkins.vm.network "forwarded_port", guest: 8080, host: 8080
      jenkins.vm.synced_folder ".", "/vagrant", disabled: true
      jenkins.vm.provision "shell", inline: $jenkins_setup
  
      jenkins.vm.provider "virtualbox" do |vb|
        vb.customize [ "modifyvm", :id, "--uartmode1", "file", "/dev/null" ]
        vb.name = "jenkins"
        vb.memory = 2048
      end
    end
  
    config.vm.define "registry" do |registry|
      registry.vm.box = "ubuntu/focal64"
      registry.vm.hostname = "registry.intranet"
      registry.vm.network "private_network", ip: "172.16.43.101"
      registry.vm.synced_folder ".", "/vagrant", disabled: true
  
      registry.vm.provider "virtualbox" do |vb|
        vb.customize [ "modifyvm", :id, "--uartmode1", "file", "/dev/null" ]
        vb.name = "registry"
        vb.memory = 2048
      end
    end
  end
  
  $hosts_setup = <<~SCRIPT
    set -e
    echo "[HOST FILE SETUP]"
  
    echo "[TASK 1] -- Set up jenkins name resolution"
    echo "172.16.43.100       jenkins jenkins.intranet" >> /etc/hosts
  
    echo "[TASK 2] -- Set up registy name resolution"
    echo "172.16.43.101       registry registry.intranet" >> /etc/hosts
  SCRIPT
  
  $update_system = <<~SCRIPT
    set -e
    echo "[UPDATE SYSTEM]"
    export DEBIAN_FRONTEND=noninteractive
  
    echo "[TASK 1] -- Syncing repos"
    apt-get update &>/dev/null
  
    echo "[TASK 2] -- Updating packages"
    apt-get upgrade -y &>/dev/null
  SCRIPT
  
  $jenkins_setup = <<~SCRIPT
    set -e
  
    echo "[INSTALL JENKINS]"
  
    echo "[TASK 1] -- Adding apt-keys"
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add - &>/dev/null
    echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
  
    echo "[TASK 2] -- Syncing repos"
    apt-get update &>/dev/null
  
    echo "[TASK 3] -- Installing Jenkins dependencies"
    apt-get -y install default-jre default-jdk git git-ftp &>/dev/null
  
    echo "[TASK 4] -- Installing jenkins"
    apt-get -y install jenkins &>/dev/null
    systemctl enable jenkins &>/dev/null
    systemctl start jenkins &>/dev/null
  
    JENKINS_INITIAL_PASSWORDD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"
  
    echo "[TASK 5] -- Wait for Jenkin's initialAdminPassword file to be created"
    while ! test -f "$JENKINS_INITIAL_PASSWORDD_FILE"; do sleep 1; done
  
    echo "------------------------------------"
    echo "Jenkins initialAdminPassword:\t$(cat $JENKINS_INITIAL_PASSWORDD_FILE)"
    echo "------------------------------------"
  SCRIPT
  

```

Crearemos las máquinas utilizando el comando:

```bash
$ vagrant up
```

### Configurando el registry

El primer paso será configurar el registry con autenticación de usuarios y certificados TLS. Para ello fuera de las máquinas virtuales creamos el siguiente bash script con nombre `create-certs.sh` al lado de nuestro `Vagrantfile` con el siguiente contenido:

`./create-certs.sh`

```bash
#!/bin/bash

# Delete folder if exist
rm -rf registry-certs

# Create destination folder
mkdir -p registry-certs

# Create Certificate Authority
echo "Creating Certificate Authority"
echo -e '\n\n' | docker run --rm -i -v $PWD/registry-certs:/out squareup/certstrap init --common-name ca

# Create Certificate Sign Request for registry
echo "Creating Certificate Sign Request for registry.intranet"
echo -e '\n\n' | docker run --rm -i -v $PWD/registry-certs:/out squareup/certstrap request-cert -domain registry.intranet

# Sign CSR with Certificate Authority
echo "Creating registry.intranet certificate"
docker run --rm -it -v $PWD/registry-certs:/out squareup/certstrap sign registry.intranet --CA ca

# Create Certificate Sign Request for jenkins
echo "Creating Certificate Sign Request for jenkins.intranet"
echo -e '\n\n' | docker run --rm -i -v $PWD/registry-certs:/out squareup/certstrap request-cert -domain jenkins.intranet

# Sign CSR with Certificate Authority
echo "Creating jenkins.intranet certificate"
docker run --rm -it -v $PWD/registry-certs:/out squareup/certstrap sign jenkins.intranet --CA ca
```

Le damos permisos de ejecución:

```bash
$ chmod +x ./create-certs.sh
```

Ejecutamos el script:

```bash
$ ./create-certs.sh
```

Esto nos generará el directorio `registry-certs` con los certificados de la CA, jenkins y registry:

```
registry-certs/
├── ca.crl
├── ca.crt
├── ca.key
├── jenkins.intranet.crt
├── jenkins.intranet.csr
├── jenkins.intranet.key
├── registry.intranet.crt
├── registry.intranet.csr
└── registry.intranet.key
```

Ahora copiaremos los certificados del registry a la máquina virtula `registry`. Buscaremos las credenciales para conectarnos al registry mediante:

```bash
$ vagrant ssh-config registry
```

Nos devolverá un resulatado com el siguiente:

```bash
Host registry
  HostName 127.0.0.1
  User vagrant
  Port 2201
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/myuser/registry-demos/.vagrant/machines/registry/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

Con esto sabremos en qué puesto está escuchando en local y la clave privada para conectarnos. Crearemos el directorio que contendrá los certificados del registry mediante el comando:

```bash
$ ssh -p 2201 -i /Users/myuser/registry-demos/.vagrant/machines/registry/virtualbox/private_key vagrant@localhost mkdir /home/vagrant/registry_certs
```

Copiaremos tanto el certificado como la clave privada mediante los siguientes comandos:

```bash
$ scp -P 2201 -i /Users/myuser/registry-demos/.vagrant/machines/registry/virtualbox/private_key ./registry-certs/registry.intranet.crt vagrant@localhost:/home/vagrant/registry_certs
$ scp -P 2201 -i /Users/myuser/registry-demos/.vagrant/machines/registry/virtualbox/private_key ./registry-certs/registry.intranet.key vagrant@localhost:/home/vagrant/registry_certs
```

Ahora que tenemos los certificados entraremos en la máquina de `registry` mediante:

```bash
$ vagrant ssh registry
```

Una vez dentro crearemos los ficheros necesarios para utilizar nuestro registry con autenticación. Para ello, primero crearemos el directorio `auth`:

```bash
vagrant@registry:~$ mkdir registry_auth
```

Generamos un fichero `htpasswd` con usuario con contraseña mediante:

```bash
vagrant@registry:~$ docker run --rm \
  -v $PWD/registry_auth:/auth \
  registry:2.7.0 \
  sh -c "htpasswd -Bbn devops secretpassword > /auth/htpasswd"
```

Creamos por último un directorio para contener las imágenes del registry:

```bash
vagrant@registry:~$ mkdir registry_data
```

Con esto tenemos lo necesario para arrancar nuestro registry:

```bash
vagrant@registry:~$ docker run \
  -d \
  -p 443:443 \
  --name registry \
  -v /home/vagrant/registry_data:/var/lib/registry \
  -v /home/vagrant/registry_certs:/certs:ro \
  -v /home/vagrant/registry_auth:/auth:ro \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
  -e "REGISTRY_HTTP_ADDR=0.0.0.0:443" \
  -e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.intranet.crt" \
  -e "REGISTRY_HTTP_TLS_KEY=/certs/registry.intranet.key" \
  registry:2
```

Podemos verificar que la autenticación funciona mediante:

```bash
vagrant@registry:~$ docker login -u devops -p secretpassword https://registry.intranet
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/vagrant/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
vagrant@registry:~$
```

### Configurando acceso de máquina jenkins al registry

Para poder utilizar el registry necesitaremos copiar los certificados generados (cliente) para Jenkins en la carpeta de certificados de docker. Para ello primero buscaremos las credenciales de vagrant para poder conectarnos:

```bash
$ vagrant ssh-config jenkins
```

Nos devolverá algo parecido a esto:

```
Host jenkins
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /Users/jaimesalaszancada/Documents/trainings/devops-fundamentals/02_docker/08_docker_registry/02-certificados-TLS/02-jenkins-access-private-registry/.vagrant/machines/jenkins/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

Con esto sabremos en qué puerto está escuchando en local y la clave privada para conectarnos. Procedemos a crear el directorio que contendrá los certificados:

```bash
$ ssh -p 2200 -i /Users/myuser/registry-demos/.vagrant/machines/jenkins/virtualbox/private_key vagrant@localhost sudo mkdir -p /etc/docker/certs.d/registry.intranet
```

Para copiar los certificados lo haremos de forma distinta al registry ya que el directorio `/etc/docker/certs.d/` requiere permisos de superusuario. Copiaremos tanto `jenkins.intranet.crt` (renombrándolo a `jenkins.intranet.cert`), `jenkins.intranet.key` y `ca.crt`:

```bash
$ cat ./registry-certs/jenkins.intranet.crt | ssh -p 2200 -i /Users/myuser/registry-demos/.vagrant/machines/jenkins/virtualbox/private_key vagrant@127.0.0.1 "sudo tee -a /etc/docker/certs.d/registry.intranet/jenkins.intranet.cert >/dev/null"
$ cat ./registry-certs/jenkins.intranet.key | ssh -p 2200 -i /Users/myuser/registry-demos/.vagrant/machines/jenkins/virtualbox/private_key vagrant@127.0.0.1 "sudo tee -a /etc/docker/certs.d/registry.intranet/jenkins.intranet.key >/dev/null"
$ cat ./registry-certs/ca.crt | ssh -p 2200 -i /Users/myuser/registry-demos/.vagrant/machines/jenkins/virtualbox/private_key vagrant@127.0.0.1 "sudo tee -a /etc/docker/certs.d/registry.intranet/ca.crt >/dev/null"
```

Con esto ya tenemos todo listo para poder autenticarnos con el registry desde el cliente docker de Jenkins. Podemos verificarlo entrando en la máquina de jenkins y haciendo login con las credenciales:

```bash
$ vagrant ssh jenkins
vagrant@jenkins:~$ docker login -u devops -p secretpassword https://registry.intranet
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/vagrant/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

Ya tenemos la connectividad lista para poder utilizar el registry desde la pipeline.