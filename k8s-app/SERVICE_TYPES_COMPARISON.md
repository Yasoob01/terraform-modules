# Kubernetes Service Types Comparison

## Quick Reference

| Type | Access | IP Address | Use Case | Cost |
|------|--------|------------|----------|------|
| **ClusterIP** | Internal only | Cluster-internal IP | Internal services, microservices | Free |
| **NodePort** | External via Node IP | Node's IP + Port (30000-32767) | Development, testing | Free |
| **LoadBalancer** | External via public IP | Public IP from cloud provider | Production apps | Paid (cloud LB cost) |
| **ExternalName** | Internal (DNS alias) | External DNS name | External services | Free |

## Detailed Comparison

### 1. ClusterIP (Default)
- **Accessibility**: Only from within the cluster
- **IP**: Internal cluster IP (e.g., `10.96.0.1`)
- **Port**: Any port you specify
- **Use Cases**:
  - Internal microservices communication
  - Databases (MySQL, PostgreSQL)
  - Redis, Memcached
  - Internal APIs
- **Example**: Frontend → Backend API (both in cluster)

### 2. NodePort
- **Accessibility**: External via any Node's IP
- **IP**: Any Node's IP address
- **Port**: Static port 30000-32767 (or auto-assigned)
- **Use Cases**:
  - Development/testing
  - When LoadBalancer is not available
  - Direct access to specific nodes
- **Example**: `http://192.168.1.10:30080` (Node IP + NodePort)

### 3. LoadBalancer
- **Accessibility**: External via public IP
- **IP**: Public IP from cloud provider (AWS ELB, GCP LB, Azure LB)
- **Port**: Any port you specify
- **Use Cases**:
  - Production web applications
  - Public-facing APIs
  - User-facing services
- **Example**: `http://123.45.67.89:80` (Public LoadBalancer IP)
- **Note**: Requires cloud provider support (AWS, GCP, Azure, etc.)

### 4. ExternalName
- **Accessibility**: Internal (resolves to external DNS)
- **IP**: External DNS name (no IP assigned)
- **Port**: Any port you specify
- **Use Cases**:
  - External databases
  - Third-party APIs
  - Services outside the cluster
- **Example**: `http://external-database:5432` → resolves to `db.example.com:5432`

## Visual Flow

```
ClusterIP:
  Pod → ClusterIP Service → Other Pods (internal only)

NodePort:
  Internet → Node IP:30080 → NodePort Service → Pods

LoadBalancer:
  Internet → Public IP:80 → LoadBalancer Service → Pods

ExternalName:
  Pod → ExternalName Service → External DNS (database.example.com)
```

## Terraform Examples

### ClusterIP (Default)
```hcl
resource "kubernetes_service" "internal" {
  metadata { name = "internal-api" }
  spec {
    type = "ClusterIP"  # Can omit (default)
    selector = { app = "api" }
    port { port = 8080; target_port = 8080 }
  }
}
```

### NodePort
```hcl
resource "kubernetes_service" "nodeport" {
  metadata { name = "nodeport-app" }
  spec {
    type = "NodePort"
    selector = { app = "web" }
    port {
      port        = 80
      target_port = 8080
      node_port   = 30080  # Optional
    }
  }
}
```

### LoadBalancer
```hcl
resource "kubernetes_service" "loadbalancer" {
  metadata { name = "public-app" }
  spec {
    type = "LoadBalancer"
    selector = { app = "web" }
    port { port = 80; target_port = 8080 }
  }
}
```

### ExternalName
```hcl
resource "kubernetes_service" "external" {
  metadata { name = "external-db" }
  spec {
    type         = "ExternalName"
    external_name = "database.example.com"
    port { port = 5432 }
  }
}
```

## When to Use Which?

- **ClusterIP**: Default for internal services
- **NodePort**: Quick external access for dev/test
- **LoadBalancer**: Production apps needing public access
- **ExternalName**: Connecting to services outside Kubernetes

