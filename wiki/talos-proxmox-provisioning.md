# Talos on Proxmox Provisioning

This homelab utilizes extreme automation for bootstrapping Kubernetes. Rather than manually juggling Talos ISOs in Proxmox and issuing network configs piecemeal, we use **Omni Infrastructure Providers** and the official **Talos Proxmox Plugin**.

## The Architecture

A separate Docker container (`omni-proxmox`) securely communicates with BOTH your Omni server (via gRPC/HTTPS) and your Proxmox hypervisor API.

- **On Omni**: The provider registers itself and listens for "Cluster Creation" and "Machine Class" requests.
- **On Proxmox**: The provider natively executes VM construction, connects virtual hard disks, configures vNIC bounds on predefined VLANs, and maps the official Talos images remotely.

This provides a fully declarative process where you just request a "Control Plane node with 2 CPUs running Talos v1.X" and Omni spawns the literal server.

## Installation & Version Mechanics

Our deployment tracks the **latest** available version tags for both `ghcr.io/siderolabs/omni` and `ghcr.io/siderolabs/omni-infra-provider-proxmox`.

- **Important**: Drifts in API versions between the provider and Omni (for instance, the lack of `cosi.resource.State` availability) can cause connection looping. Updating both cleanly usually fixes unhandled RPC errors.
- **Network Traffic**: The Provider accesses `omni.krapulax.dev:8443` internally on the docker loop (proxy network).

## Utilizing `omnictl`

To codify machine deployment without UI clicking:

1. **Get Authenticated**: Export an `omniconfig` YAML token directly from the Omni user UI profile dropdown.
2. **Merge Config**:
   ```bash
   omnictl config merge ~/Downloads/omniconfig.yaml
   ```
3. **Declare Class**: Construct `.yaml` files dictating hardware slices (RAM, Disk, CPU, VLAN).
4. **Deploy**:
   ```bash
   omnictl apply -f machine-classes/control-plane.yaml
   ```

Omni will intercept the API object, inform the provider, spawn the Proxmox VM, boot Talos, and tunnel the connection back via SideroLink seamlessly.
