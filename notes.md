Summary:
1 mgmt cluster only (hybrid)
- Since Gloo Mesh and the Gloo Mesh Agent are in the same cluster, we can configure both to communicate over ClusterIP
gloo mesh 2.0.9
istio 1.13.4 with revisions
north/south gateway only

mgmt ingress exposing:

# admin workspace
argocd at on port 443 at /argo
host: argocd.glootest.com, argocd-local.glootest.com

gloo mesh on port 443 
host: gmui.glootest.com, gmui-local.glootest.com
- this endpoint is protected by extauth

grafana on port 443 at /grafana
host: grafana.glootest.com, grafana-local.glootest.com

httpbin on 80 at /get
host: httpbin.glootest.com, httpbin-local.glootest.com
- this route is rate limited at 20 req/sec
- when you are rate limited, the transformationfilter provides a pretty message
- log4j WAF policy enabled on this route

# httpbin workspace
httpbin on 443 at /get
host: httpbin.glootest.com, httpbin-local.glootest.com
- this endpoint is protected by extauth
- this route has no rate limits once logged in
- this route has OPA policy attached
    - users with @solo.io can access path /get and path with prefix /anything
    - users with @gmail.com can only access exact path /anything/protected
- JWTPolicy enabled - extracts x-email and x-organization claims to headers
- Transformation policy extracts the x-organization header from x-email header using regex
- log4j WAF policy enabled on this route

# bookinfo workspace
bookinfo on 80 at /productpage
host: bookinfo.glootest.com, bookinfo-local.glootest.com
- this route is rate limited at 15 req/sec
- when you are rate limited, the transformationfilter provides a pretty message
- log4j WAF policy enabled on this route

bookinfo on 443 at /productpage
host: bookinfo.glootest.com, bookinfo-local.glootest.com
- this endpoint is protected by extauth
- this route has no rate limits once logged in
- log4j WAF policy enabled on this route

# bank-lob workspace
Solo Wallet demo on 80 at /
host: bank.glootest.com, bank-local.glootest.com
- Example using (https://github.com/GoogleCloudPlatform/bank-of-anthos) repo
- modified to live in `bank-demo` namespace and have service accounts
- modified frontend.yaml `BANK_NAME` env variable to be Solo Wallet :)
- credentials should be autopopulated testuser/bankofanthos

# collaboration tools workspace
Collaboration tools workspace has the following apps

ghost blog on 443 at /
host: ghost.glootest.com ghost-local.glootest.com
- example shows route table delegation with root, delegate1, and delegate 2 route tables
```
delegate 1 - at prefix: /
- this route is publicly available
- this route is rate limited at 40 req/min
delegate 2 - at prefix: /ghost
- the admin page at the /ghost endpoint is protected by oidc
- storage persisted with pvc using external local-storage storageclass
```
- this route has no rate limits once logged in

plants blog on 443 at /
host: plants.glootest.com, plants-local.glootest.com
- this route is publicly available
- the admin page at the /ghost endpoint is protected by basic auth
- storage persisted with pvc using internal local-storage storageclass

drawio on 443 at /
host: drawio.glootest.com, drawio-local.glootest.com

etherpad on 443 at /
host: etherpad.glootest.com
- storage persisted with pvc using local-storage storageclass

# Example outputs
Get all RouteTables
```
 % k get rt -A
NAMESPACE             NAME                 AGE
gloo-mesh             grafana-ui-443       49m
collaboration-tools   drawio-rt-443        49m
collaboration-tools   etherdraw-rt-443     49m
gloo-mesh             gm-ui-rt-443         49m
argocd                mgmt-argo-rt-443     49m
collaboration-tools   etherpad-rt-443      49m
httpbin               httpbin-rt-80        49m
bookinfo-frontends    productpage          49m
httpbin               httpbin-rt-443       49m
bookinfo-frontends    productpage-rt-443   49m
collaboration-tools   delegated-table-2    25m
collaboration-tools   ghost-blog-rt-443    25m
collaboration-tools   delegated-table-1    25m
collaboration-tools   plants-blog-rt-443   25m
bank-demo             bank-demo-rt-80      13m
```

Get all VirtualServices
```
% k get vs -A
NAMESPACE        NAME                                                              GATEWAYS                                                              HOSTS                                                     AGE
istio-gateways   routetable-gm-ui-rt-443-gloo-mesh-mgmt-gateways                   ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["gmui.glootest.com","gmui-local.glootest.com"]           46m
istio-gateways   routetable-etherdraw-rt-443-collaboration-tools-mgmt-gateways     ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["etherdraw-local.glootest.com"]                          46m
istio-gateways   routetable-httpbin-rt-80-httpbin-mgmt-gateways                    ["virtualgateway-mgmt-north-south-286d032add3e8f1fa2b48be5f56d82c"]   ["httpbin.glootest.com","httpbin-local.glootest.com"]     46m
istio-gateways   routetable-productpage-rt-443-bookinfo-frontends-mgmt-gateways    ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["bookinfo.glootest.com","bookinfo-local.glootest.com"]   46m
istio-gateways   routetable-httpbin-rt-443-httpbin-mgmt-gateways                   ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["httpbin.glootest.com","httpbin-local.glootest.com"]     46m
istio-gateways   routetable-grafana-ui-443-gloo-mesh-mgmt-gateways                 ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["grafana.glootest.com","grafana-local.glootest.com"]     46m
istio-gateways   routetable-drawio-rt-443-collaboration-tools-mgmt-gateways        ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["drawio-local.glootest.com"]                             46m
istio-gateways   routetable-mgmt-argo-rt-443-argocd-mgmt-gateways                  ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["argocd.glootest.com","argocd-local.glootest.com"]       46m
istio-gateways   routetable-productpage-bookinfo-frontends-mgmt-gateways           ["virtualgateway-mgmt-north-south-286d032add3e8f1fa2b48be5f56d82c"]   ["bookinfo.glootest.com","bookinfo-local.glootest.com"]   46m
istio-gateways   routetable-etherpad-rt-443-collaboration-tools-mgmt-gateways      ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["etherpad-local.glootest.com"]                           46m
istio-gateways   routetable-plants-blog-rt-443-collaboration-tools-mgmt-gateways   ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["plants-local.glootest.com"]                             24m
istio-gateways   routetable-bank-demo-rt-80-bank-demo-mgmt-gateways                ["virtualgateway-mgmt-north-south-286d032add3e8f1fa2b48be5f56d82c"]   ["bank.glootest.com","bank-local.glootest.com"]           12m
istio-gateways   routetable-ghost-blog-rt-443-collaboration-tools-mgmt-gateways    ["virtualgateway-mgmt-north-south-3a8909b00a555ea00176f30bb58cb2f"]   ["ghost-local.glootest.com"]
```