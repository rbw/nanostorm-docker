#!/usr/bin/env sh

NGINX_FILE="/etc/nginx/nginx.conf"
PROXY_FILE="/etc/nginx/conf.d/proxy.conf"
UPSTREAM_FILE="/etc/nginx/conf.d/upstream.conf"

# Get the number of workers for Nginx, default to 1
USE_NGINX_WORKER_PROCESSES=${WORKER_PROCESSES:-1}

# Modify the number of worker processes in Nginx config
sed -i "/worker_processes\s/c\worker_processes ${USE_NGINX_WORKER_PROCESSES};" ${NGINX_FILE}

# Get the listen port for Nginx, default to 80
USE_LISTEN_PORT=${LISTEN_PORT:-80}

echo "server {" > ${PROXY_FILE}

if [[ "${USE_SSL}" == 1 && -f /certs/cert.crt && -f /certs/cert.key ]] ; then
    echo "listen ${USE_LISTEN_PORT} ssl;
          ssl_certificate        /certs/cert.crt;
          ssl_certificate_key    /certs/cert.key;
    " >> ${PROXY_FILE}
else
    echo "listen ${USE_LISTEN_PORT};" >> ${PROXY_FILE}
fi

echo "upstream nanostorm {" > ${UPSTREAM_FILE}

rpc_proxies=${NANOSTORM_SERVERS:-"localhost:15001"}
for proxy in ${rpc_proxies//,/ }; do
    echo "server $proxy;" >> ${UPSTREAM_FILE}
done;

echo "}" >> ${UPSTREAM_FILE}

echo "location / {
          try_files \$uri @app;
      }
      location @app {
          limit_req zone=req_limit burst=5 nodelay;
          proxy_pass http://nanostorm;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      }
}" >> ${PROXY_FILE}

exec "$@"
