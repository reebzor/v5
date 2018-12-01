# Simple Dockerfile to run my website in a container

FROM nginx

COPY . /usr/share/nginx/html

EXPOSE 80

CMD ["/usr/sbin/nginx"]