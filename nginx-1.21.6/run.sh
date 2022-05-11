#!/bin/bash
#  添加模块的编译命令
./configure --prefix=/usr/local/nginx --with-http_realip_module --with-http_addition_module --with-http_gzip_static_module --with-http_secure_link_module --with-http_stub_status_module --with-stream --with-pcre=/root/nginx_folds/pcre-8.41 --with-zlib=/root/nginx_folds/zlib-1.2.11 --with-openssl=/root/nginx_folds/openssl-1.1.0g --add-module=/root/nginx_folds/ngx_http_location_count_module

make -j4 && make install

nginx -s stop
nginx -c ./conf/nginx.conf  # 启动nginx
