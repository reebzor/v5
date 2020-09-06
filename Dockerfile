FROM nginx:stable-alpine

LABEL maintainer="Tom Reeb <tom@reeb.me>" \
      name="tomreeb/dotcom" \
      version="3.0"

COPY ./html /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]