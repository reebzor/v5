# Simple Dockerfile to run my website in a container
# to run: docker run -d --name tomreeb-web -p 8080:80
FROM nginx

MAINTAINER Tom Reeb <tom@reeb.me>

COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["/usr/sbin/nginx"]