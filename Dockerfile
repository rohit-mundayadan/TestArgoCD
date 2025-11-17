FROM nginx:alpine

# Copy the pre-generated index.html
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
