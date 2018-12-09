FROM nginx:alpine

LABEL maintainer="Tom Reeb <tom@reeb.me>" \
      name="tomreeb/dotcom" \
      version="1.0"

COPY ./html /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]