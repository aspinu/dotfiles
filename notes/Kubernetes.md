    - Swicth 8 Port
    - Rack 6U

## Software

### OS

    //- NIX OS maybe -> search for alternative

    - Talos Linux

## Kubernets

    - K3S
    - Helm
    - Kustomzie
    - ArgoCD maybe
    - NGINX ingress controller
    - external DNS - helm chart

### CSI

    - Longhorn

### LoadBalancer

     - MetalLB

### Monitoring

    - Grafana
    - Prometheus

> [!IMPORTANT]Experimental
>
> - OpenTelemetry

### Other Stuff

    - pi-hole
    - gitlab
    - pdf thing
    - nextCLoud services

#### CLIs

    - Helm
    - nmcli

---

> [!IMPORTANT]

### Multi node condfig

Step 1.

CONTROL_PLANE_IP=("192.168.178.95" "192.168.178.96" "192.168.178.97")

talosctl gen config talos-cluster <https://192.168.178.250:6443> --install-disk /dev/nvme0n1

talosctl gen config talos-cluster <https://192.168.178.95:6443> --install-disk /dev/nvme0n1
talosctl gen config talos-cluster <https://192.168.178.96:6443> --install-disk /dev/nvme0n1
talosctl gen config talos-cluster <https://192.168.178.97:6443> --install-disk /dev/nvme0n1

talosctl apply-config --insecure --nodes 192.168.178.95 --file controlplane.yaml --config-patch @allow-workers.yaml
talosctl apply-config --insecure --nodes 192.168.178.96 --file controlplane.yaml --config-patch @allow-workers.yaml
talosctl apply-config --insecure --nodes 192.168.178.97 --file controlplane.yaml --config-patch @allow-workers.yaml

export CLUSTER_NAME=talos-cluster

--

bootstrap

# Configure your local talosctl to talk to the nodes

talosctl config endpoint 192.168.178.95 192.168.178.96 192.168.178.97
talosctl config node 192.168.178.95

# Start the cluster

talosctl bootstrap
talosctl bootstrap --nodes 192.168.178.95 --endpoints 192.168.178.95 --talosconfig ~/.talos/config  
--

talosctl kubeconfig .
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes

---

Operations

Talos Shust down nodes

talosctl shutdown --nodes 192.168.178.95
talosctl shutdown --nodes 192.168.178.96
talosctl shutdown --nodes 192.168.178.97

---

Things to install on the K8s cluster

- [x] First install Cilium

- [x] Cilium
- [x] FluxCD
- [x] Longhorn CSI
- [ ] Load Balanver -> MetalLB or other
- [ ] Traefik
- [ ] Nginx Ingress controlloer
- [ ] Dns with pi-hole
- [ ] Pdf Stuff
- [ ] git/gitlab for self Hosting
- [ ] Prooetheus
- [ ] grafana
- [ ] Databases
- [ ] Use Cloudflare for extenral exposure
- [ ] my Go app -> Expenseapp
- [ ] coreDNS

- [-] Homepage

> [!TODO ]

- [x] Cilium

> [!IMPORTANT] Config from Gemini -- This one works

```
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium --version 1.19.4 \
  --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set kubeProxyReplacement=true \
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
  --set cgroup.autoMount.enabled=false \
  --set cgroup.hostRoot=/sys/fs/cgroup \
  --set k8sServiceHost=localhost \
  --set k8sServicePort=7445 \
  --set l7Proxy=true \
  --set hubble.enabled=true \
  --set hubble.tls.enabled=false
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true
```

> [!IMPORTANT] Config From Sidero Talos

```
helm install \
    cilium \
    cilium/cilium \
    --version 1.18.0 \
    --namespace kube-system \
    --set ipam.mode=kubernetes \
    --set kubeProxyReplacement=true \
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \
    --set cgroup.autoMount.enabled=false \
    --set cgroup.hostRoot=/sys/fs/cgroup \
    --set k8sServiceHost=localhost \
    --set k8sServicePort=7445

```

helm install cilium oci://quay.io/cilium/charts/cilium \
 --version 1.19.4 \
 --namespace kube-system

> [!CAUTION] This does not work use old fashion way from above

---

helm upgrade cilium oci://quay.io/cilium/charts/cilium \
 --version 1.19.4 \
 --namespace kube-system

> [!CAUTION] This does not work use old fashion way from above

---

---

FluxCD

```
flux bootstrap github \
  --owner=your-github-org \
  --repository=your-gitops-repo \
  --branch=main \
  --path=./clusters/your-cluster
```

Used config

```
flux bootstrap github \
  --token-auth \
  --owner=aspinu \
  --repository=talos-lab-cluster\
  --branch=main \
  --path=clusters/talos-lab-cluster \
  --personal
```

---

CSI -> Longhorn

1. Patch talos to allow iscsi-tools

```
customization:
  systemExtensions:
    officialExtensions:
      - siderolabs/iscsi-tools
      - siderolabs/util-linux-tools
```

Patch running node talos

`talosctl patch mc --nodes 192.168.178.95 --patch longhorn-patch.yaml`
`talosctl patch mc --nodes 192.168.178.96 --patch longhorn-patch.yaml`
`talosctl patch mc --nodes 192.168.178.97 --patch longhorn-patch.yaml`

-- Very officialExtensions
`talosctl -n 192.168.178.95 get extensions`

> [!CAUTION] Crashed after installing patch pod securityContext

> [!TIP] Reboted nodes in maintenace, reset config and then re-apply confing with --insecure on all nodes
> config endpont and bootstrap endpoint agian -> FIX

ID for upgrade with scsi drivers

`talosctl upgrade --nodes 192.168.178.97 --image factory.talos.dev/metal-installer/613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245:v1.13.2`

Pod security

`kubectl label ns longhorn-system pod-security.kubernetes.io/enforce=privileged namespace/longhorn-system labeled`

#### Inatall longhort via FluxCD

`kubectl create ns longhorn-system
flux create source helm longhorn-repo \
  --url=https://charts.longhorn.io \
  --namespace=longhorn-system \
  --export > helmrepo.yaml
kubectl apply -f helmrepo.yaml`

done

---

MetalLB

> [!TODO]

- [ ] Exclide MetalLB range from router ex 192.168.178.200 - 192.168.178.254
- [ ] install metal lb with kustomize and flux

---

- [x] Kustomize + FLux

### Repos struct from Gemini

.
├── apps/ # Your own custom workloads
│ └── expenseapp/
│ ├── helmrelease.yaml
│ └── kustomization.yaml
│
├── clusters/ # ONLY configuration entry points live here
│ └── home-cl-1/
│ ├── flux-system/ # LEAVE ALONE (Managed by Flux bootstrap)
│ │ ├── gotk-components.yaml
│ │ └── gotk-sync.yaml
│ ├── infrastructure.yaml # Activates everything in infrastructure/clusters/home-cl-1
│ └── apps.yaml # Activates everything in apps/
│
└── infrastructure/ # The warehouse for all third-party software
├── base/ # Standard blueprint for each tool
│ ├── cilium/
│ ├── grafana/
│ ├── ingress-nginx/
│ ├── longhorn/ # Your Longhorn Helm files go right here!
│ │ ├── helmrepo.yaml
│ │ ├── helmrelease.yaml
│ │ └── kustomization.yaml
│ ├── metallb/
│ ├── pi-hole/
│ ├── prometheus/
│ └── traefik/
│
└── clusters/ # The control panel where you pick what to turn on
└── home-cl-1/
└── kustomization.yaml # The master list (You toggle your tools on/off here)

---
