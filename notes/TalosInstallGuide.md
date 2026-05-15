# Talos Cluster 3 Nodes VIP (Virtual IP)

## Prerequisites

### PC

1. Flash Talos BareMetal on USB Drive
2. Set up bios Boot order on each PC
3. Boot from Flash -> Talos -> Talso will erase the entire disk automatically

### Home Network Router

1. On boot PC will automatically recieve IP Addres - set up fix ip in router
   or set beforehand an ip for the specific MAC if MAC Addres is availabe

## Installation

1. Install Talos Linux on all PCs (select harddrive not flash drive)
2. Identify hard drive name and network interface name (F3 for network config)

   `talosctl get disks --insecure --nodes node-ip-address`

## Configuration

1. Generate secrets.yaml file for the cluster
   `talosctl gen secrets -o secrets.yaml`

2. Generate config and specifiy the VIP Endpoint, does not need to run talos,can be any free IP from the Network

`talosctl gen config talos-lab-cluster https://192.168.178.250:6443 --with-secrets secrets.yaml --install-disk /dev/nvme0n1`

    This will create clonstralplane.yaml, talosconfig and worker.yaml files.

1. Add the VIP config at the end of contrloplane.yaml, for link name use Network interface indetified in Instalation step 2. and add the designated VIP IP

   ```
   -
   apiVersion: v1alpha1
   kind: Layer2VIPConfig
   name: VIP-ip-address # IP address to be advertised as a Layer 2 VIP.
   link: eno1 # Name of the link to assign the VIP to.

   ```

1. Add an additional yaml, or change controlplane yaml to allow scheduling on controlplane nodes

   ```

    cluster:
     allowSchedulingOnControlPlanes: true

   ```

1. Apply Config on each of the members

   `talosctl apply-config --insecure --nodes 192.168.178.95 --file controlplane.yaml --config-patch @allow-workers.yaml`
   `talosctl apply-config --insecure --nodes 192.168.178.96 --file controlplane.yaml --config-patch @allow-workers.yaml`
   `talosctl apply-config --insecure --nodes 192.168.178.97 --file controlplane.yaml --config-patch @allow-workers.yaml`

1. Add nodes to talos config

   `talosctl config endpoint 192.168.178.95 192.168.178.96 192.168.178.97`
   `talosctl bootstrap --nodes 192.168.178.95 --endpoints 192.168.178.95 --talosconfig ~/.talos/config`

1. Generate Kubeconfig

`talosctl kubeconfig --node 192.168.178.95`
