FROM nginx:alpine

RUN apk add --no-cache git python3 python3-dev py3-pip uwsgi

RUN mkdir -p /var/www/
RUN mkdir -p /usr/local/githubprapi/luajit/lib
WORKDIR /var/www/
RUN git clone https://github.com/ganeshkj/GitHubPRAPI.git

COPY nginx.conf         /etc/nginx/
COPY *.vhost            /etc/nginx/conf.d/
COPY lib/prometheus.lua /usr/local/githubprapi/luajit/lib
RUN nginx -t

EXPOSE 80 9147

ENTRYPOINT ["./start.sh start"]