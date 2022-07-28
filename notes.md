Summary:
1 mgmt cluster only
- Since Gloo Mesh and the Gloo Mesh Agent are in the same cluster, we can configure both to communicate over ClusterIP
gloo mesh 2.0.9
istio 1.13.4 with revisions
north/south and east/west gateways
cert manager deployed in cert-manager namespace

Note:
All route tables are using wildcard "*" for their hostnames which makes testing simpler but can result in routes clashing

mgmt ingress exposing:

argocd on port 80

gloo mesh on port 443 

httpbin on port 80 at /get and /anything - delegated route tables

httpbin on port 443 at /get and /anything