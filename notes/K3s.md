# Setup

## Hardware

    - 3x HP EliteDesk 800 G3 16GB i5 6500T 256SSD
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
