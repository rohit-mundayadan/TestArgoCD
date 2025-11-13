FROM nginx:alpine

# Add a custom index.html to identify the version
RUN echo "<html><head><title>ArgoCD Test App</title></head><body><h1>ArgoCD Image Updater Test</h1><p>Version: ${VERSION}</p><p>Git Hash: ${GIT_HASH}</p></body></html>" > /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
