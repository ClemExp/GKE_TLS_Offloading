# Enable Metrics for Prometheus

## Ensure changes were made in traefik values yaml when deployed

Prometheus should have been enabled by default and prometheus service is enabled: 

```
metrics:
  prometheus:
    serviceMonitor:
    service:
      enabled: true

```

## Validate metrics endpoint

```
kubectl get endpoints -A
kubectl get svc -A
```


As we already deployed a metrics ingressroute to traefik for metrics: we can validate the metrics directly via: https: traefik.x.com/metrics/ otherwise we can do this via checking the pods internally

Run temporary pod (sh) within cluster to get metrics.
```
kubectl run -it --rm --image alpine -- sh
```

```
apk add curl
curl traefik-metrics.traefik.svc.cluster.local:9100/metrics
```
Ensure metrics are available via above curl within cluster (<svc>.<namespace>.svc.cluster.local..)

# Installing Prometheus stack using Helm 

We will install Kube-Prometheus-Stack with only key required components: Prometheus, Grafana and Metrics exporter. We are not interested in alert manager or other components for now.

## Add the repository to helm repo

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## Modify values YAML 

Modify the prometheus / grafana stack values yaml
- Add custom scrape configuration for traefik metrics
- Add Grafana dashboard(s) for traefik as JSON. You can also import the chart manually once Grafana is deployed. 

## Install Kube Prometheus Stack

```
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack -f stack-promo-grafana-values.yaml
```

## Create Service Monitor that connects with Traefik Dashboard Metrics Service


```
kubectl apply -f traefik-service-monitor.yaml

```

## Create port-forward to Promethues to explore data


```
kubectl port-forward service/prometheus-stack-kube-prom-prometheus 9090:9090
```

Go to http://localhost:9090/service-discovery to see whether Traefik target has been added. 


## Create port-forward to login to the Grafanato view Traefik dashboard

```
kubectl port-forward service/prometheus-stack-grafana 8080:80
```

Go to http://localhost:8080/ to login to grafana
Login credentials can be taken from Kubernetes secrets:

```
kubectl get secrets prometheus-stack-grafana -o jsonpath='{.data.admin-user}'|base64 -d
kubectl get secrets prometheus-stack-grafana -o jsonpath='{.data.admin-password}'|base64 -d
```


## Note

The following setup does not use persistence, so once restarted the stack components all data will be lost. This can be setup in prometheus configuration to persist if required
