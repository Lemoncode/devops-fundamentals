## Overview of Docker Compose

Compose is a tool for defining and running multi-container Docker applications. With Compose, you use a YAML file to configure your application’s services. Then, with a single command, you create and start all the services from your configuration. 

### Docker Compose References

[docker-compose reference](https://docs.docker.com/compose/reference/)

### Common use cases

* Development environments
* Automated testing environments
* Single host deployments


* Using Compose is basically a three-step process:
    1. Define your app's environment with a `Dockerfile` so it can be reproduced anywhere
    2. Define the services that make up your app in docker-compose.yml so they can be run together in an isolated environment.
    3. Run docker-compose up and Compose starts and runs your entire app.


```yaml
version: "3.8"
services:
  web:
    build: .
    ports:
      - "5000:5000"
    volumes:
      - .:/code
      - logvolume01:/var/log
    links:
      - redis
  redis:
    image: redis
volumes:
  logvolume01: {}
```

[Demo simple docker-compose]('07_docker_compose/docker-compose.00_nginx.yml')

> Walk through 07_docker_compose/docker-compose.00_nginx.yml

### Docker Compose Up

From the root folder where is the `docker-compose.yml` we can start to user `docker-compose` commands.

```bash
$ docker-compose up
```

The matter with this, is what happen when we have more than a docker-compose file, we can use the flag `-f` to specify the file

```bash
$ docker-compose -f docker-compose.00_nginx.yml up
```

If we want that our service run on detach mode we can use `-d` flag.

```bash
$ docker-compose -f docker-compose.00_nginx.yml up -d
```

### Docker Compose Stop/Kill

```bash
$ docker-compose -f docker-compose.00_nginx.yml stop
$ docker-compose -f docker-compose.00_nginx.yml kill
```


### Docker Compose Start

```bash
$ docker-compose -f docker-compose.00_nginx.yml start
```

### Docker Compose Restart

```bash
$ docker-compose -f docker-compose.00_nginx.yml restart
```

### Docker Compose Logs

```bash
$ docker-compose -f docker-compose.00_nginx.yml logs -f
```

### Docker Compose Validations

> Introduce an error on ports entry

```bash
$ docker-compose -f docker-compose.01_wrong_config.yml config
ERROR: In file './docker-compose.01_wrong_config.yml', service 'ports' must be a mapping not an array.
```

### Docker Compose List Containers

```bash
$ docker-compose ps
```

### Docker Compose List Processes

```bash
$ docker-compose top 
```

### Docker Compose Down


```bash
$ docker-compose down 
```

###  Docker Compose CMD

We can also `override` for a given service the contianer's `CMD`

```
nginx:
  image: nginx:latest
  ports:
    - "8080:80"
  command: [nginx-debug, '-g', 'daemon off;']
```

### Docker Compose ENTRYPOINT

`override` the default entry point

```
nginx:
  image: nginx:latest
  ports:
    - "8080:80"
  entrypoint: [nginx-debug, '-g', 'daemon off;']
```

### Docker Compose restart

`no` is the default restart policy, and it does not restart a container under any circumstance. When `always` is specified, the container always restarts. The `on-failure` policy restarts a container if the exit code indicates an on-failure error. `unless-stopped` always restarts a container, except when the container is stopped (manually or otherwise).

```
nginx:
  image: nginx:latest
  ports:
    - "8080:80"
  restart: always
```

## Docker Compose Apps Examples

### Python Web 

1. Create a new file `app.py`

```py
import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6739)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.routes('/')
def hello():
    count = get_hit_count()
    return 'Hello World! I have been seen {} times.\n'.format(count)
```

2. Create  another file called `requirements.txt`

```
flask
redis
```

3. Create a `Dockerfile`

```Dockerfile
FROM python:3.7-alpine

WORKDIR /code

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

RUN apk add --no-cache gcc musl-dev linux-headers

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

EXPOSE 5000

COPY app.py app.py

CMD [ "flask", "run" ]
```

4. Define services in a Compose file

* Create `docker-compose.yml` as follows:

```yml
version: "3.8"
services:
  web:
    build: .
    ports:
      - "5000:5000"
  redis:
    image: "redis:alpine"
```

We define two services: `web` and `redis`

5. Build and run your app with Compose

```bash
$ docker-compose up
```

6. Edit the Compose file to add a bind mount

```diff
version: "3.8"
services:
  web:
    build: .
    ports:
      - "5000:5000"
+   volumes:
+     - .:/code
+   environment:
+     FLASK_ENV: development
  redis:
    image: "redis:alpine"
```

The new `volumes` key mounts the project directory (current directory) on the host to `/code` inside the container, allowing you to modify the code on the fly, without having to rebuild the image. The environment key sets the FLASK_ENV environment variable, which tells flask run to run in development mode and reload the code on change. This mode should only be used in development.

7. Update the application.  Modify `app.py` as follows to realise that the application is updated on the fly:

```diff
import time

import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
-   return 'Hello World! I have been seen {} times.\n'.format(count)
+   return 'Hello from Docker! I have been seen {} times.\n'.format(count)
```

8. Experiment with some other commands

```bash
$ docker-compose -d
...
$ docker-compose ps
            Name                           Command               State           Ports         
-----------------------------------------------------------------------------------------------
02_python_web_compose_redis_1   docker-entrypoint.sh redis ...   Up      6379/tcp              
02_python_web_compose_web_1     flask run                        Up      0.0.0.0:5000->5000/tcp
```

The docker-compose run command allows you to run one-off commands for your services. For example, to see what environment variables are available to the web service:

```bash
$ docker-compose run web env
Creating 02_python_web_compose_web_run ... done
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=4c22f7eec4b0
TERM=xterm
FLASK_ENV=development
LANG=C.UTF-8
GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
PYTHON_VERSION=3.7.9
PYTHON_PIP_VERSION=20.2.4
PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/fa7dc83944936bf09a0e4cb5d5ec852c0d256599/get-pip.py
PYTHON_GET_PIP_SHA256=6e0bb0a2c2533361d7f297ed547237caf1b7507f197835974c0dd7eba998c53c
FLASK_APP=app.py
FLASK_RUN_HOST=0.0.0.0
HOME=/root
```

```bash
$ docker-compose down stop
```

```bash
$ docker-compose down --volumes
```
