FROM alpine:latest
RUN apk add --no-cache nginx bash curl
RUN mkdir -p /var/www/html /run/nginx
RUN echo "<h1>Layanan Web Simulasi Kelompok 5</h1>" > /var/www/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
