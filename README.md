# Helm Charts

## Paper-MC

Chart: [papermc](https://github.com/SirNiggo/helm/tree/main/charts/papermc)

Originally created by [gabibbo97](https://github.com/gabibbo97)

### Requirements

* Traefik for [IngressRouteTCP](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/#kind-ingressroutetcp)

  * Traefik must have a dedicated entrypoint for every MC server and TCP protocols (TCP; best is 25565 as default port)

  Traefik config:

  ```
  ports:
    mc1-tcp:
      expose: true
      exposedPort: 25565
      port: 25565
      protocol: TCP
  ```