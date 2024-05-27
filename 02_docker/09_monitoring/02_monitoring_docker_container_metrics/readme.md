
- Create `prometheus/prometheus.yml`

```yml
scrape_configs:
- job_name: cadvisor
  scrape_interval: 5s
  static_configs:
  - targets:
    - cadvisor:8080
```

```yaml
services:
  cadvisor:
    privileged: true
    container_name: cadvisor
    build:
      context: ./cadvisor
      dockerfile: Dockerfile
      args:
        VERSION: "v0.44.0"
      cache_from:
        - golang:buster
        - alpine:latest
    command:
      - '--allow_dynamic_housekeeping=true'
      - '--housekeeping_interval=30s'
      - '--docker_only=true'
      - '--storage_duration=1m0s'
      - '--event_storage_age_limit=default=0'
      - '--event_storage_event_limit=default=0'
      - '--global_housekeeping_interval=30s'
      - '--disable_metrics=accelerator,cpu_topology,disk,memory_numa,tcp,udp,percpu,sched,process,hugetlb,referenced_memory,resctrl,cpuset,advtcp,memory_numa'
      - '--store_container_labels=false'
    restart: unless-stopped
    devices:
      - /dev/kmsg:/dev/kmsg
    expose:
      - 8080
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /etc/machine-id:/etc/machine-id:ro
      - /var/run/docker.sock:/var/run/docker.sock

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - 9090:9090
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    depends_on:
      - cadvisor
```

Now we can visit `http://localhost:9090/graph` and run some conatiner metrics, for example:

```
container_start_time_seconds{name="prometheus"}
```