# Cluster Access (Load balancers, certificates, DNS, ingress..)

After base cluster creation via terraform; load balancers, TLS security, certificates, DNS etc needs to be put in place.

This section details the setup involved.

## Creation of static IP

Steo 0 - now handled by terraform

## Certificate management
Google certs:
- Provided by cloud provider
- Faster processing time
. Provisioning quite automatic
- Complexity reduced

Certificate management implications:
- Found out later issue with kubernetes secrets

For Cluster TLS E2E - handled by TF
For Cluster TLS Termination - ???

## Ingress route creation - external cluster access

Wait for synch
Monitor with events, kubectl describe ingress etc...
Wait for LB to be created

Verify load balancer:
Auto creation via ingress
Front end configuration
Backend configuration
Healthchecks

## DNS configuration

Configure DNS records in google domains

## Traefik ingress routes

Should be handled now by TF
