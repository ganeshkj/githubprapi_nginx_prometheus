#Based on manual compile instructions at http://wiki.nginx.org/HttpLuaModule#Installation
FROM ubuntu:16.04 as nginx-lua

ENV VER_NGINX_DEVEL_KIT=0.3.1rc1
ENV VER_LUA_NGINX_MODULE=0.10.13
ENV VER_NGINX=1.13.12
ENV VER_LUAJIT=2.0.5

ENV NGINX_DEVEL_KIT ngx_devel_kit-${VER_NGINX_DEVEL_KIT}
ENV LUA_NGINX_MODULE lua-nginx-module-${VER_LUA_NGINX_MODULE}
ENV NGINX_ROOT=/etc/nginx

ENV LUAJIT_LIB /usr/local/lib
ENV LUAJIT_INC /usr/local/include/luajit-2.0

# ***** BUILD DEPENDENCIES *****
# Common dependencies (Nginx and LUAJit) - make
# Nginx dependencies - libpcre3 libpcre3-dev zlib1g-dev libssl-dev 
# LUAJit dependencies - gcc

RUN apt-get -qq update
RUN apt-get -qq -y install wget libpcre3 libpcre3-dev zlib1g-dev libssl-dev make gcc

# ***** DOWNLOAD AND UNTAR *****

# Download
RUN wget http://nginx.org/download/nginx-${VER_NGINX}.tar.gz
RUN wget http://luajit.org/download/LuaJIT-${VER_LUAJIT}.tar.gz
RUN wget https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGINX_DEVEL_KIT}.tar.gz -O ${NGINX_DEVEL_KIT}.tar.gz
RUN wget https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX_MODULE}.tar.gz -O ${LUA_NGINX_MODULE}.tar.gz
# Untar
RUN tar -xzvf nginx-${VER_NGINX}.tar.gz && rm nginx-${VER_NGINX}.tar.gz
RUN tar -xzvf LuaJIT-${VER_LUAJIT}.tar.gz && rm LuaJIT-${VER_LUAJIT}.tar.gz
RUN tar -xzvf ${NGINX_DEVEL_KIT}.tar.gz && rm ${NGINX_DEVEL_KIT}.tar.gz
RUN tar -xzvf ${LUA_NGINX_MODULE}.tar.gz && rm ${LUA_NGINX_MODULE}.tar.gz

# ***** BUILD FROM SOURCE *****

# LuaJIT
WORKDIR /LuaJIT-${VER_LUAJIT}
RUN make
RUN make install
# Nginx with LuaJIT
WORKDIR /nginx-${VER_NGINX}
RUN ./configure --prefix=${NGINX_ROOT} --with-ld-opt="-Wl,-rpath,${LUAJIT_LIB}" --add-module=/${NGINX_DEVEL_KIT} --add-module=/${LUA_NGINX_MODULE}
RUN make -j2
RUN make install
RUN ln -s ${NGINX_ROOT}/sbin/nginx /usr/local/sbin/nginx

# ***** CLEANUP *****
RUN rm -rf /nginx-${VER_NGINX}
RUN rm -rf /LuaJIT-${VER_LUAJIT}
RUN rm -rf /${NGINX_DEVEL_KIT}
RUN rm -rf /${LUA_NGINX_MODULE}
# TODO: Uninstall build only dependencies?
# TODO: Remove env vars used only for build?

FROM nginx-lua
# update and install the dependencies for Python web application 

RUN apt-get -qq update && apt-get -qq -y install git python3 python3-dev python3-pip uwsgi build-essential
RUN pip3 install uwsgi

#Create user nginx to run nginx
RUN useradd --no-create-home nginx

#git clone the web application to /var/www
RUN mkdir -p /var/www/
WORKDIR /var/www/
RUN git clone https://github.com/ganeshkj/GitHubPRAPI.git

#setup the env for GitHubPRAPI
RUN python3 GitHubPRAPI/setup.py install

#create directories and files required for nginx
RUN mkdir -p /var/log/nginx/
RUN touch /var/log/nginx/access.log && chmod +rw /var/log/nginx/access.log
RUN touch /var/log/nginx/error.log && chmod +rw /var/log/nginx/error.log
RUN mkdir -p /usr/local/openresty/luajit/lib

#copy the required nginx conf files for web application and prometheus metrics
COPY nginx.conf         /etc/nginx/conf/nginx.conf
COPY *.vhost            /etc/nginx/conf.d/

#copy the prometheus lua dependency for nginx
COPY lib/prometheus.lua /usr/local/openresty/luajit/lib

#verfiy nginx config files
RUN nginx -t

EXPOSE 80 9147

CMD /var/www/GitHubPRAPI/start.sh start && nginx -g "daemon off;"

