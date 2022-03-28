# Istio setup

To allow external traffic into our mesh and configure routing to our  app, we will need to create an Istio Gateway and Virtual Service. Open a file called `istio.yaml` for the manifest:

`infrastructure/math-gateway.yaml`

```yml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: math-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "*"

```

Let's apply this to the cluster by running:

```bash
kubectl apply -f infrastructure/math-gateway.yaml
gateway.networking.istio.io/math-gateway created
```

To have a look on gateway DNS

```bash
kubectl -n istio-system get svc
# ....
istio-ingressgateway        LoadBalancer   10.100.33.182    a4f317d30ca394c2ca3629ac2cfec68d-2122476700.eu-west-3.elb.amazonaws.com   15020:31519/TCP,80:31054/TCP,443:31807/TCP,15029:31782/TCP,15030:31032/TCP,15031:31578/TCP,15032:31104/TCP,31400:30200/TCP,15443:31352/TCP   5h19m
# ....
```

To check that our infrastructure is working let's connect our math service to the `gateway`

```bash
git checkout develop
```

`kube/canary-deployment.yaml`

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: stuff
spec:
  hosts:
    - "*"
  gateways:
    - math-gateway
  http:
    - route:
        - destination:
            host: math

```

Update `Jenkinsfile`

```diff
stage('Canary Deploy') {
          when {
            branch 'production'
          }
          steps {
            script {
              if (params.CANARY_DEPLOYMENT) {
                versioningLatestAndPushImage(imageName, 'v2')
                cleanLocalImages(imageName, 'v2')
+               withKubeConfig([credentialsId: 'K8S-FILE', serverUrl: 'https://0762874B88CC99AED4773002D066C462.sk1.eu-west-3.eks.amazonaws.com']) {
+                 sh 'kubectl apply -f kube/canary-deployment.yaml'
+               }
              } else {
                versioningLatestAndPushImage(imageName, 'v1')
                cleanLocalImages(imageName, 'v1')
                withKubeConfig([credentialsId: 'K8S-FILE', serverUrl: 'https://0762874B88CC99AED4773002D066C462.sk1.eu-west-3.eks.amazonaws.com']) {
                  sh 'kubectl apply -f kube/app-deployment.yaml'
                }
              }
            }
          }
        }
```

Update all branches with new `develop` code.

```bash
git checkout staging
git merge develop
git push
```

```bash
git checkout main
git merge staging
git push
```

```bash
git checkout production
git merge main
git push
```

Go to Jenkins server, and wait until `production` pipeline finishes. Now trigger a new `Build with parameters`, ensure that  `CANARY_DEPLOYMENT` is checked, and click `Build`.

Open a browser and paste `http://a4f317d30ca394c2ca3629ac2cfec68d-2122476700.eu-west-3.elb.amazonaws.com/api/sum?a=2&b=2`