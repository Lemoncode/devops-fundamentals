# Connect Jenkins with Kubernetes

## Steps

### 1. Grab credentials

We are going to create a file that will contain the credentials in orderto make that Jenkins can connect with our cluster.

```bash
$ mkdir kube-config
$ touch kube-config/config
```

Copy the contents on `~/.kube/config` into `kube-config/config` 

### 2. Install Plugins Jenkins

Go to `Manage Jenkins` -> `Manage Plugins` -> Select `Available` -> Search for `Kubernetes CLI Plugin` -> Install and restart Jenkins

To get the official plugin documentation follow this link: [Kubernetes CLI Plugin reference](https://plugins.jenkins.io/kubernetes-cli/)

### 3. Set credentials on Jenkins

* Go to `Jenkins` -> `Add Credentials` -> `Kind` - Secret file -> Choose File 
* Select the previous created file: `config`.
* `ID` - K8S-FILE
* `Description` - K8S-FILE


### 4. Set anonymous role

In order to be able to deploy to this cluster we are going to create the anonymous role.

```bash
$ kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
clusterrolebinding.rbac.authorization.k8s.io/cluster-system-anonymous created
```

### 5. Setup AWS crednetials

```bash
docker exec -it jenkins-blueocean bash
```

Access to AWS IAM credentials that you have used to create teh cluster, if are the same in your system, you can find out by:

```bash
$ cat ~/.aws/credentials 
```

Inside the running container

```bash
$ aws configure set aws_access_key_id <your aws access key id>
$ aws configure set aws_secret_access_key <your aws secret access key>
```

### 6. Check cluster connectivity

We need to provide the cluster server url, navigate to `AWS console`, select `EKS service`. Once we're there:

Select `lc-cluster` -> Select `Configuartion` tab -> Copy `API server endpoint`

On Jenkins create a `New item` -> name it `k8s-cluster-test` -> and select `Pipeline` -> and click on `Ok`

On pipeline definition create the following Pipeline

```groovy
pipeline {
  agent any
  stages {
    stage('Test cluster connectivity') {
      steps {
        withKubeConfig([credentialsId: 'K8S-FILE', serverUrl: 'your API server endpoint']) {
          sh 'kubectl get ns'
        }
      }
    }
  }
}
```

Apply the Pipeline and check output by running it, the expected output:

```
+ kubectl get ns
NAME              STATUS   AGE
default           Active   13h
istio-system      Active   97m
kube-node-lease   Active   13h
kube-public       Active   13h
kube-system       Active   13h
[Pipeline] }
[kubernetes-cli] kubectl configuration cleaned up
```