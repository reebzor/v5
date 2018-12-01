FROM nginx:alpine

LABEL maintainer="Tom Reeb <tom@reeb.me>"

COPY ./html /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g daemon off;"]