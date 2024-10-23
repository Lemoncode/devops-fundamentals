# Prepare Canary Environment

In order to have a Canary Deployment we need to provide an infrastructure, that handles the traffic load to each version in our application. Also we have to be capable to observe the behavior of the new released version. To achieve all these goals, we're going to create a Kubernete cluster, with Prometheus, Grafana and Istios.

* Istios - Will let us manage ingress Traffic
* Prometheus - Monitoring our code
* Grafana - The interpreter for Prometheus

## Pre requisites

* `AWS IAM` with enough privileges to create a cluster
* `eksctl`
* `kubectl`
* `helm`

We will deal with Istio installation on future steps on this demo.

## Steps

### 1. Create a new directory to handle infrastructure

```bash
mkdir infrastructure
```

Let's start by create a new cluster:

`infrastructure/create-cluster.yaml`

```yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: lc-cluster
  region: eu-west-3
  version: "1.28"

managedNodeGroups:
  - name: lc-nodes
    instanceType: t2.small
    desiredCapacity: 2
    minSize: 1
    maxSize: 3

```

Configure AWS CLI

> You need AWS_ACCESS_KEY and AWS_ACCESS_SECRET_KEY

```bash
aws configure
```

Start the cluster by running

```bash
eksctl create cluster -f infrastructure/create-cluster.yaml
```

Once the cluster is deployed a simple test that we can do is run the following command:

```bash
kubectl get nodes
```

### 2. Install Prometheus and Grafana via Helm

#### What is Prometheus?

Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active developer and user community. It is now a standalone open source project and maintained independently of any company. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

#### What is Grafana?

Grafana is open source visualization and analytics software. It allows you to query, visualize, alert on, and explore your metrics no matter where they are stored. In plain English, it provides you with tools to turn your time-series database (TSDB) data into beautiful graphs and visualizations.

Let's start by adding the Helm repos related to helm

```bash
# add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# add grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts

```

### 3. Deploy Prometheus

First we are going to install Prometheus. In this example, we are primarily going to use the standard configuration, but we do override the storage class. We will use gp2 EBS volumes for simplicity and demonstration purpose. When deploying in production, you would use io1 volumes with desired IOPS and increase the default storage size in the manifests to get better performance. Run the following command:

```bash
helm install prometheus prometheus-community/prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"
```

Check if Prometheus deployed as expected

```bash
kubectl get all
```

In order to access the Prometheus server URL, we are going to use the kubectl port-forward command to access the application.

```bash
kubectl port-forward -n default deploy/prometheus-server 8081:9090
```

Now we can visit on `localhost:8081`


Once Prometheus is installed, shows up on console where we can find the related resources, if we do:

```bash
export POD_NAME=$(kubectl get pods --namespace default -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
kubectl describe $POD_NAME 
```

We will find out that the POD is listening on port 9090

### 4. Deploy Grafana

Create `infrastructure/grafana.yaml`

```yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-server
        access: proxy
        isDefault: true
```

From `./infrastructure`, run:

```bash
helm install grafana grafana/grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='LC_WTF!sThis' \
    --values ./grafana.yaml \
    --set service.type=LoadBalancer
```

You can get Grafana ELB URL using:

```bash
export ELB=$(kubectl get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"

```

Log into Grafana using `admin` and the previous password. Ensure that `Prometheus` data source is available.

### 5. Deploy Istio

#### Download Istio

Change directory to `infrastructure`

> We will use istio version `1.5.2`

```bash
$ mkdir environment
$ cd environment
``` 

To download the last istio version

```bash
$ curl -L https://istio.io/downloadIstio | sh -
```

To download a specific version we can use

```bash
$ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.5.2 TARGET_ARCH=x86_64 sh -
```

* The installation directory contains:
  * Installation YAML files for Kubernetes 
  * Sample applications in `samples/`
  * The `istioctl` client binary in the `bin/` directory (`istioctl` is used when manually injecting Envoy as sidecar proxy).

To install in our system

```bash
$ cd ./environment/istio-1.5.2

$ sudo cp -v bin/istioctl /usr/local/bin/
```

To just running during bash session

```bash
$ cd ./environment/istio-1.5.2
$ export PATH=$PWD/bin:$PATH
```

We can verify that we have the proper version in our $PATH

```bash
istioctl version --remote=false
```

#### Install Istio 

1. For this installation, we use the demo [configuration profile](https://istio.io/latest/docs/setup/additional-setup/config-profiles/). It's selected to have a good set of defaults for testing, but there are other profiles for production or performance testing.

Istio will be installed in the `istio-system` namespace. 

```bash
istioctl manifest apply --set profile=demo
```

We can verify all the services have been installed

```bash
kubectl -n istio-system get svc
``` 

and check the corresponding pods with

```bash
kubectl -n istio-system get pods
```

In order to take advantage of all of Istio’s features pods must be running an Istio sidecar proxy.

Istio offers two ways injecting the Istio sidecar into a pod:

* **Manually** using the `istioctl` command. Manual injection directly modifies configuration, like deployments, and injects the proxy configuration into it.
* **Automatically** using the Istio sidecar injector. You will still need to maually enable Istio in each namespace that you want to be managed by Istio.

> We will install the application inside default namespace and allow Istio to automatically Inject the Sidecar

```bash
kubectl label namespace default istio-injection=enabled
```
