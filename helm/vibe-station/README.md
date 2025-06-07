# Vibe Station Helm Chart

A Helm chart for deploying Vibe Station - An agentic developer experience platform with code-server, Nix, and Home Manager.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-vibe-station`:

```bash
helm install my-vibe-station ./helm/vibe-station
```

The command deploys Vibe Station on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-vibe-station` deployment:

```bash
helm delete my-vibe-station
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `nameOverride`            | String to partially override vibe-station.name | `""`  |
| `fullnameOverride`        | String to fully override vibe-station.fullname | `""`  |

### Image parameters

| Name                | Description                                          | Value                                 |
| ------------------- | ---------------------------------------------------- | ------------------------------------- |
| `image.repository`  | Vibe Station image repository                        | `ghcr.io/0xbigboss/vibe-station`      |
| `image.tag`         | Vibe Station image tag (immutable tags are recommended) | `latest`                             |
| `image.pullPolicy`  | Vibe Station image pull policy                       | `IfNotPresent`                        |
| `imagePullSecrets`  | Vibe Station image pull secrets                      | `[]`                                  |

### Deployment parameters

| Name                                    | Description                                                                               | Value   |
| --------------------------------------- | ----------------------------------------------------------------------------------------- | ------- |
| `replicaCount`                          | Number of Vibe Station replicas to deploy                                                | `1`     |
| `podAnnotations`                        | Annotations for Vibe Station pods                                                        | `{}`    |
| `podSecurityContext`                    | Set Vibe Station pod's Security Context                                                  | `{}`    |
| `securityContext.privileged`            | Set to true for Docker-in-Docker support                                                 | `true`  |
| `securityContext.runAsNonRoot`          | Set Vibe Station container's Security Context runAsNonRoot                              | `true`  |
| `securityContext.runAsUser`             | Set Vibe Station container's Security Context runAsUser                                 | `1000`  |

### Service parameters

| Name                  | Description                                          | Value       |
| --------------------- | ---------------------------------------------------- | ----------- |
| `service.type`        | Vibe Station service type                            | `ClusterIP` |
| `service.port`        | Vibe Station service HTTP port                       | `7080`      |
| `service.targetPort`  | Vibe Station container HTTP port                     | `7080`      |

### Ingress parameters

| Name                  | Description                                          | Value                    |
| --------------------- | ---------------------------------------------------- | ------------------------ |
| `ingress.enabled`     | Enable ingress record generation for Vibe Station   | `false`                  |
| `ingress.className`   | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+) | `""` |
| `ingress.annotations` | Additional annotations for the Ingress resource     | `{}`                     |
| `ingress.hosts`       | An array with hosts and paths                        | `[{"host": "vibe-station.local", "paths": [{"path": "/", "pathType": "Prefix"}]}]` |
| `ingress.tls`         | TLS configuration for Vibe Station hostname         | `[]`                     |

### Persistence parameters

| Name                                        | Description                                              | Value              |
| ------------------------------------------- | -------------------------------------------------------- | ------------------ |
| `persistence.nixStore.enabled`             | Enable persistence for Nix store                        | `true`             |
| `persistence.nixStore.storageClass`        | Storage class for Nix store                              | `""`               |
| `persistence.nixStore.accessMode`          | Access mode for Nix store                               | `ReadWriteOnce`    |
| `persistence.nixStore.size`                | Size of Nix store                                       | `10Gi`             |
| `persistence.codeServerData.enabled`       | Enable persistence for code-server data                 | `true`             |
| `persistence.codeServerData.storageClass`  | Storage class for code-server data                      | `""`               |
| `persistence.codeServerData.accessMode`    | Access mode for code-server data                        | `ReadWriteOnce`    |
| `persistence.codeServerData.size`          | Size of code-server data                                | `5Gi`              |
| `persistence.dockerImages.enabled`         | Enable persistence for Docker images (DinD)             | `true`             |
| `persistence.dockerImages.storageClass`    | Storage class for Docker images                         | `""`               |
| `persistence.dockerImages.accessMode`      | Access mode for Docker images                           | `ReadWriteOnce`    |
| `persistence.dockerImages.size`            | Size of Docker images storage                           | `20Gi`             |
| `persistence.appData.enabled`              | Enable persistence for application data                 | `false`            |
| `persistence.appData.storageClass`         | Storage class for application data                      | `""`               |
| `persistence.appData.accessMode`           | Access mode for application data                        | `ReadWriteOnce`    |
| `persistence.appData.size`                 | Size of application data storage                        | `10Gi`             |
| `persistence.appData.existingClaim`        | Use existing PVC for application data                   | `""`               |

### Vibe Station Configuration

| Name                                        | Description                                              | Value              |
| ------------------------------------------- | -------------------------------------------------------- | ------------------ |
| `vibeStation.codeServer.appName`            | Code Server app name                                     | `vibe-station`     |
| `vibeStation.codeServer.auth`               | Code Server authentication method                        | `none`             |
| `vibeStation.codeServer.bindAddr`           | Code Server bind address                                 | `0.0.0.0:7080`     |
| `vibeStation.environment`                   | Environment variables for the container                  | `{"LANG": "en_US.UTF-8", "LC_ALL": "en_US.UTF-8"}` |
| `vibeStation.ssh.enableAuthSock`            | Enable SSH auth sock mounting                            | `false`            |
| `vibeStation.ssh.authSockPath`              | Path to SSH auth sock on host                            | `/run/host-services/ssh-auth.sock` |
| `vibeStation.docker.enabled`               | Enable Docker-in-Docker                                  | `true`             |
| `vibeStation.docker.useHostDocker`          | Use host Docker daemon instead of DinD                   | `false`            |
| `vibeStation.docker.hostDockerSocket`       | Host Docker socket path                                   | `/var/run/docker.sock` |

### Resource parameters

| Name                        | Description                                              | Value      |
| --------------------------- | -------------------------------------------------------- | ---------- |
| `resources.limits.cpu`      | The CPU limit for the Vibe Station container            | `2000m`    |
| `resources.limits.memory`   | The memory limit for the Vibe Station container         | `4Gi`      |
| `resources.requests.cpu`    | The requested CPU for the Vibe Station container        | `500m`     |
| `resources.requests.memory` | The requested memory for the Vibe Station container     | `1Gi`      |

### Autoscaling parameters

| Name                                            | Description                                                                                                          | Value   |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------- |
| `autoscaling.enabled`                           | Enable Horizontal Pod Autoscaler (HPA) for Vibe Station                                                             | `false` |
| `autoscaling.minReplicas`                       | Minimum number of Vibe Station replicas                                                                             | `1`     |
| `autoscaling.maxReplicas`                       | Maximum number of Vibe Station replicas                                                                             | `3`     |
| `autoscaling.targetCPUUtilizationPercentage`    | Target CPU utilization percentage                                                                                    | `80`    |
| `autoscaling.targetMemoryUtilizationPercentage` | Target Memory utilization percentage                                                                                 | `""`    |

### ServiceAccount parameters

| Name                         | Description                                                            | Value  |
| ---------------------------- | ---------------------------------------------------------------------- | ------ |
| `serviceAccount.create`      | Specifies whether a ServiceAccount should be created                  | `true` |
| `serviceAccount.name`        | The name of the ServiceAccount to use.                                | `""`   |
| `serviceAccount.annotations` | Additional Service Account annotations (evaluated as a template)      | `{}`   |

### Other parameters

| Name                       | Description                                          | Value   |
| -------------------------- | ---------------------------------------------------- | ------- |
| `nodeSelector`             | Node labels for Vibe Station pods assignment        | `{}`    |
| `tolerations`              | Tolerations for Vibe Station pods assignment        | `[]`    |
| `affinity`                 | Affinity for Vibe Station pods assignment           | `{}`    |

## Examples

### Basic installation

```bash
helm install my-vibe-station ./helm/vibe-station
```

### Installation with ingress enabled

```bash
helm install my-vibe-station ./helm/vibe-station \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=vibe-station.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

### Installation with custom resources

```bash
helm install my-vibe-station ./helm/vibe-station \
  --set resources.requests.cpu=1000m \
  --set resources.requests.memory=2Gi \
  --set resources.limits.cpu=4000m \
  --set resources.limits.memory=8Gi
```

### Installation with host Docker daemon

```bash
helm install my-vibe-station ./helm/vibe-station \
  --set vibeStation.docker.useHostDocker=true \
  --set persistence.dockerImages.enabled=false
```

## Accessing Vibe Station

After installation, follow the instructions in the NOTES.txt output to access your Vibe Station instance.

For LoadBalancer service type:
```bash
export SERVICE_IP=$(kubectl get svc --namespace default my-vibe-station --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo http://$SERVICE_IP:7080
```

For ClusterIP service type (port-forward):
```bash
export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=vibe-station,app.kubernetes.io/instance=my-vibe-station" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace default port-forward $POD_NAME 7080:7080
```

Then open http://localhost:7080 in your browser.

## Troubleshooting

### Pod fails to start with permission errors

If you see permission errors, ensure that:
1. The security context is correctly configured
2. The storage class supports the required access modes
3. The node has sufficient privileges for Docker-in-Docker if enabled

### Storage issues

If persistent volumes are not being created:
1. Check that your cluster has a default storage class
2. Verify the storage class supports the requested access modes
3. Ensure sufficient storage is available in your cluster

### Docker-in-Docker not working

If Docker commands fail inside the container:
1. Ensure `securityContext.privileged` is set to `true`
2. Check that the container has the necessary capabilities
3. Verify that Docker images persistence is working correctly