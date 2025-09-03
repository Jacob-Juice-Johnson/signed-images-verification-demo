# Simple test application for container signing demo
FROM nginx:alpine

# Add custom index page
RUN echo '<!DOCTYPE html>' > /usr/share/nginx/html/index.html && \
    echo '<html><head><title>Container Signing Demo</title></head>' >> /usr/share/nginx/html/index.html && \
    echo '<body>' >> /usr/share/nginx/html/index.html && \
    echo '<h1>🔐 Container Signing Demo Application</h1>' >> /usr/share/nginx/html/index.html && \
    echo '<p>This is a test application for demonstrating:</p>' >> /usr/share/nginx/html/index.html && \
    echo '<ul>' >> /usr/share/nginx/html/index.html && \
    echo '<li>Azure Container Registry</li>' >> /usr/share/nginx/html/index.html && \
    echo '<li>Container Image Signing with Notation</li>' >> /usr/share/nginx/html/index.html && \
    echo '<li>Ratify Admission Control</li>' >> /usr/share/nginx/html/index.html && \
    echo '</ul>' >> /usr/share/nginx/html/index.html && \
    echo '<p>Build time: '"$(date)"'</p>' >> /usr/share/nginx/html/index.html && \
    echo '</body></html>' >> /usr/share/nginx/html/index.html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Install curl for health check
RUN apk add --no-cache curl

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
