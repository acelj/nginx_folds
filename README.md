## 编译
> 多模块一起编译
`./configure --prefix=/usr/local/nginx --with-http_realip_module --with-http_addition_module --with-http_gzip_static_module --with-http_secure_link_module --with-http_stub_status_module --with-stream --with-pcre=/root/nginx_folds/pcre-8.41 --with-zlib=/root/nginx_folds/zlib-1.2.11 --with-openssl=/root/nginx_folds/openssl-1.1.0g`
`make -j4 && make install`

## 启动
`./sbin/nginx -c ./conf/nginx.conf`
`nginx -c /usr/local/nginx/conf/nginx.conf`   添加环境变量在哪都能启动


## 添加环境变量
在~/.bashrc 文件末尾添加
`export PATH=/usr/local/nginx/sbin/:$PATH`
source ~/.bashrc

## 默认配置文件讲解
```c
#user  nobody;                      // 指定用户和用户组，在某些项目的时候需要更改的为root
worker_processes  1;                // 一个master进程fork几个work进程
daemon off;                         // 是否以守护进程方式运行nginx， gdb调试nginx 选择off， 默认选择on
master_process on;                  // 是否以master、worker方式工作
                                    // 几乎所有产品是以一个master进程多个woker进程工作的，不过为了方便调试，选择off后，master就不会fork 出worker进程来处理请求，而是用master进程自身来处理请求。


#error_log  logs/error.log;         // error 日志设置， 后面跟着等级， 默认error
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;         // pid path/file;  保存master进程ID的pid文件存放路径。默认与configure
                                    // 执行时的参数“--pid-path”所指定的路径是相同的，也可以随时修改，但应确保Nginx有权在相应的目标中创建pid文件，该文件直接影响Nginx是否可以运行。


events {
    worker_connections  1024;       // 每个worker进程最大连接数
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;          // 指定了客户端与服务器长连接的超时时间，超过这个时间，服务器将关闭连接。

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}

```

## 自定义配置文件讲解
```conf

worker_processes 4;         // fork 多少worker进程


events {
	worker_connections 1024;    // 每个worker进程最多处理多少连接
}


# 添加一个http模块， 监听了4个不同端口
#  
http {
	server {
		listen 8888;           
	}
	server {
		listen 8889;
	}
	server {
		listen 8890;

		location ~ \.cgi {
			fastcgi_pass 192.168.232.134:9000;
			fastcgi_index index.cgi;
			fastcgi_param SCRIPT_FILENAME cgi$fastcgi_script_name;
			include ../conf/fastcgi_params;
		}
	}

    # 这是负载均衡， 默认是轮询方式， 还有其他几种方式，权重、ip_hash(保留session)、fair、url_hash
	upstream backend {          
                server 192.168.xxx.xxx weight=2;   
                server 192.168.xxx.xxx weight=1;
        }

	server {
		listen 8891;

        # 负载均衡是http模块里面的，不是server里面的，不能放在这里
#		upstream backend {    
#			server 192.168.xx.xxx;
#			server 192.168.xx.xxx;
#		}		

		location / {
			root /usr/local/nginx/html;
            # 代理服务器， 和重定向是有区别的
            # 代理的网址不会变，是有代理服务器内部转到指定服务器中去，客户端是直接和代理服务器进行连接的
            # 重定向的网址是会变的，是网址直接重定向的另一个网址，然后客户端请求重新和请求的网址建立连接
#			proxy_pass http://192.168.xx.xx;   // 前面需要加上http://
			proxy_pass http://backend;
		}
        
        # 静态资源
        # 图片是直接打开的
		location /images/ {    // 网址访问的路径
			root /usr/local/nginx/;     // 实际服务器的路径， 不能重复加上images路径
		}

        # 静态资源
        # 视频是下载的，这跟浏览器有关
        # 或者需要配一个媒体格式header
        location ~ \.(mp3|mp4) {
			root /home/wangbojing/share/nginx/;
		}
	}

}


```


## 安装ag命令
`apt-get install silversearcher-ag`
`apt-get install python-ase`
