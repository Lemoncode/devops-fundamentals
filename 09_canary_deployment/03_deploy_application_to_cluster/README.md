# Deploy Application to Cluster

Let's start by align all branches code

Update staging

```bash
git checkout staging
git merge develop staging
git push
```

Update main

```bash
git checkout main
git merge staging main
git push
```

Update production

```bash
git checkout production
git merge main
git push
```

Update main with production

```bash
git checkout main
git merge production
git push
``` 

Update staging with main

```bash
git checkout staging
git merge main
git push
```

Update develop with staging

```bash
git checkout develop 
git merge staging
git push
```

Now that all our branches have the same code, ensure that you are on `develop` .

## Steps

### 1. Adding Prometheus scrapper.

In order to expose to `Prometheus` internal metrics, we're going to set up a scrapper

```bash
npm i express-prom-bundle prom-client
```

Update `src/app.ts`


```diff
import express from 'express';
import cors from 'cors';
import { envConstants } from './env.constants';
import { api } from './api';
+const promBundle = require('express-prom-bundle');
+const metricsMiddleware = promBundle({ includeMethod: true });

const app = express();
app.use(cors());
+app.use(metricsMiddleware);
app.use('/api', api);

app.listen(envConstants.PORT, () => {
  console.log(`App ready on port: ${envConstants.PORT}`);
});

```

### 2. Create a deployment for application

Create kube directory and create app-deployment.yaml.

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
          env:
            - name: PORT
              value: "80"
          ports:
            - containerPort: 80

```

### 3. Update Jenkinsfile to deploy our code to K8s cluster


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
              } else {
                versioningLatestAndPushImage(imageName, 'v1')
                cleanLocalImages(imageName, 'v1')
+               withKubeConfig([credentialsId: 'K8S-FILE', serverUrl: 'https://<eks cluster URL>']) {
+                 sh 'kubectl apply -f kube/app-deployment.yaml'
+               }
              }
            }
          }
        }
```

Check that the Pipeline works fine on Jenkins server.

### 4. Trigger production

Update staging

```bash
git checkout staging
git merge develop
git push
```

Update main

```bash
git checkout main
git merge staging
git push
```

Update production

```bash
git checkout production
git merge main
git push
```

Check the status of our cluster by running

```bash
kubectl get all
```

And to check that th API is working run 

```bash
kubectl run -it --rm --restart=Never busybox --image=gcr.io/google-containers/busybox sh
/ # wget -qO- "http://math/api/sum?a=2&b=2"
The result is 4
```