# Helm Charts

## Paper-MC

[papermc](https://github.com/SirNiggo/helm/tree/main/charts/papermc)

Originally created by [gabibbo97](https://github.com/gabibbo97)

Needs:

### Requirements

* Traefik for [IngressRouteUDP](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressrouteudp)

..* Traefik must have a dedicated entrypoint for every MC server (best is 25565 as default port) 