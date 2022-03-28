# Managing Traffic

With our Istio gateway working it's time that we set up our canary deployment to enroute network traffic depending on app version.

Let's start by updating our deployment, to make possible to have different versions, in order to Istios can target them:

```bash
git checkout develop
```

`kube/app-deployment.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: math
  annotations:
    prometheus.io/scrape: "true"
  labels:
    app: math
spec:
  selector:
    app: math
  ports:
    - name: http
      port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: math-v1
  labels:
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: math
  template:
    metadata:
      labels:
        app: math
        version: v1
    spec:
      containers:
        - name: math
          image: jaimesalas/math-api:v1
          imagePullPolicy: Always
          env:
            - name: PORT
              value: "80"
          ports:
            - containerPort: 80
# diff #
--- 
apiVersion: apps/v2
kind: Deployment
metadata:
  name: math-v2
  labels:
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: math
  template:
    metadata:
      labels:
        app: math
        version: v2
    spec:
      containers:
        - name: math
          image: jaimesalas/math-api:v2
          imagePullPolicy: Always
          env:
            - name: PORT
              value: "80"
          ports:
            - containerPort: 80
# diff #
```

With this on place we can upadate our canary deployment

`kube/canary-deployment.yaml`

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: math
spec:
  hosts:
    - "*"
  gateways:
    - math-gateway
  http:
    - route:
        - destination:
            host: math
            subset: v1 # added
          weight: 80 # added
        - destination: # added
            host: math # added
            subset: v2 # added
          weight: 80 # added
--- # added
apiVersion: networking.istio.io/v1alpha3 # added
kind: DestinationRule # added
metadata: # added
  name: math # added
spec: # added
  host: math # added
  subsets: # added
    - name: v1 # added
      labels: # added
        version: v1 # added
    - name: v2 # added
      labels: # added
        version: v2 # added

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

Update code and update branches until `main`.

Checkout `develop` and Update `src/api.ts`

```bash
$ git checkout develop
```

`src/api.ts`

```diff
import { Router } from 'express';
import { sum } from './math.helpers';

export const api = Router();

api.get('/sum', async (req, res) => {
  try {
    const params = req.query;
    const a: number = Number(params.a);
    const b: number = Number(params.b);
-   const result = `The result is in ${sum(a, b)}`;
+   const result = `The result is in v2 ${sum(a, b)}`;
    res.send(result);
  } catch (error) {
    console.log({ error });
    res.sendStatus(400);
  }
});
```

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

Go to Jenkins server, and wait until `production` pipeline finishes. Now trigger a new `Build with parameters`, ensure that  `CANARY_DEPLOYMENT` is checked, and click `Build`.

Open a browser and paste `http://a4f317d30ca394c2ca3629ac2cfec68d-2122476700.eu-west-3.elb.amazonaws.com/api/sum?a=2&b=2`

### Inspecting results

Connet to Grafana

```bash
export ELB=$(kubectl get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"
```

Click on explore and the following query:

```
rate(http_request_duration_seconds_count[30m])
```