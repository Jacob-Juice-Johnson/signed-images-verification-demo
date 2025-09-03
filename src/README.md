# Demo Application

This directory contains a simple containerized application for demonstrating container image signing and admission control.

## 📦 Application Overview

- **Base Image**: `nginx:alpine` - Lightweight web server
- **Content**: Custom HTML page showcasing the signing demo
- **Health Checks**: Built-in health monitoring
- **Security**: Vulnerability scanning ready
- **Architecture**: Multi-platform support (AMD64/ARM64)

## 🐳 Building the Application

### Prerequisites
- Docker installed
- Access to Azure Container Registry (deployed via infrastructure)

### Local Build and Test
```bash
# Build locally
docker build -t demo-app:latest .

# Test locally
docker run -p 8080:80 demo-app:latest

# Open browser to http://localhost:8080
```

### Build and Push to ACR
```bash
# Get ACR details from infrastructure
ACR_NAME=$(terraform output -raw container_registry | jq -r '.name')
ACR_LOGIN_SERVER=$(terraform output -raw container_registry | jq -r '.login_server')

# Login to ACR
az acr login --name $ACR_NAME

# Build and tag for ACR
docker build -t $ACR_LOGIN_SERVER/demo-app:latest .

# Push to ACR
docker push $ACR_LOGIN_SERVER/demo-app:latest
```

## ✍️ Container Signing Workflow

### 1. Sign the Image with Notation
```bash
# Get signing certificate details
KEY_VAULT_NAME=$(terraform output -raw key_vault | jq -r '.name')
CERT_NAME="demo-signing-kv-cert"

# Sign the container image
notation sign --signature-format cose \
    --id "https://$KEY_VAULT_NAME.vault.azure.net/keys/$CERT_NAME" \
    --plugin azure-kv \
    --plugin-config self_signed=true \
    $ACR_LOGIN_SERVER/demo-app:latest
```

### 2. Verify the Signature
```bash
# Download certificate for local verification
az keyvault certificate download \
    --vault-name $KEY_VAULT_NAME \
    --name $CERT_NAME \
    --file cert.pem

# Add certificate to notation trust store
notation cert add --type ca --store demo-trust cert.pem

# Verify the signed image
notation verify $ACR_LOGIN_SERVER/demo-app:latest
```

## 🚀 Deployment to Kubernetes

### With Ratify Admission Control
```bash
# Get AKS credentials
CLUSTER_NAME=$(terraform output -raw aks_cluster | jq -r '.name')
RESOURCE_GROUP=$(terraform output -raw resource_group | jq -r '.name')
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME

# Deploy signed image (should succeed)
kubectl run demo-app --image=$ACR_LOGIN_SERVER/demo-app:latest

# Check deployment status
kubectl get pods

# Access the application
kubectl port-forward pod/demo-app 8080:80
# Open browser to http://localhost:8080
```

### Test Admission Control
```bash
# Try to deploy unsigned image (should fail with Ratify)
kubectl run unsigned-app --image=nginx:latest

# Check rejection message
kubectl describe pod/unsigned-app
```

## 🔍 Application Features

### Custom HTML Content
The application serves a custom HTML page that displays:
- Container signing demo information
- Build timestamp
- Technology stack overview
- Responsive design

### Health Monitoring
- **Health Check Endpoint**: `GET /`
- **Check Interval**: 30 seconds
- **Timeout**: 3 seconds
- **Retry Policy**: 3 attempts
- **Startup Grace**: 5 seconds

### Security Features
- **Minimal Attack Surface**: Alpine-based image
- **No Root Processes**: Runs as nginx user
- **Read-Only Root**: Application files are immutable
- **Health Monitoring**: Early failure detection

## 🔧 Customization

### Modify Application Content
Edit the Dockerfile to customize the HTML content:

```dockerfile
# Update the RUN command to change the displayed content
RUN echo '<h1>Your Custom Title</h1>' > /usr/share/nginx/html/index.html
```

### Add Additional Files
```dockerfile
# Copy local files into the image
COPY ./static-content/ /usr/share/nginx/html/
COPY ./nginx.conf /etc/nginx/nginx.conf
```

### Environment-Specific Builds
```bash
# Build with build arguments
docker build --build-arg ENV=production -t $ACR_LOGIN_SERVER/demo-app:prod .

# Use different base images for different environments
docker build --build-arg BASE_IMAGE=nginx:stable-alpine -t $ACR_LOGIN_SERVER/demo-app:stable .
```

## 🎯 Use Cases

This demo application illustrates:

- **Container Image Signing**: How to sign images with Azure Key Vault certificates
- **Supply Chain Security**: Verification of image authenticity and integrity
- **Admission Control**: Kubernetes-level enforcement of signing policies
- **DevSecOps Integration**: Automated security scanning and signing in CI/CD
- **Multi-Architecture Support**: Building for different CPU architectures

## 📊 Image Details

### Base Image Information
- **OS**: Alpine Linux
- **Size**: ~15MB compressed
- **Security**: Regularly updated, minimal packages
- **Performance**: Fast startup, low resource usage

### Application Layers
1. **Base Layer**: nginx:alpine
2. **Content Layer**: Custom HTML content
3. **Tools Layer**: curl for health checks
4. **Config Layer**: Health check configuration

## 🐛 Troubleshooting

### Build Issues
```bash
# Check Docker daemon
docker info

# Build with verbose output
docker build --progress=plain -t demo-app .

# Check image size and layers
docker images demo-app
docker history demo-app
```

### Runtime Issues
```bash
# Check container logs
docker logs <container-id>

# Inspect running container
docker exec -it <container-id> /bin/sh

# Test health endpoint
curl -f http://localhost/
```

### Signing Issues
```bash
# Check notation installation
notation version

# List available plugins
notation plugin ls

# Check Azure Key Vault connectivity
az keyvault key list --vault-name $KEY_VAULT_NAME
```

## 📚 References

- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Notation Signing Guide](https://notaryproject.dev/docs/user-guides/how-to/sign-container-images/)
- [Nginx Docker Official Image](https://hub.docker.com/_/nginx)
- [Alpine Linux Security](https://alpinelinux.org/about/)
