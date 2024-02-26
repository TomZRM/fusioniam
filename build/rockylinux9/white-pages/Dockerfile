ARG DEPEND
ARG VERSION

FROM $DEPEND:$VERSION

EXPOSE 8080

COPY ansible/ ./

RUN bash ./run-playbook.sh install.yaml &&\
    sed -i 's/listen *80/listen 8080/g' /etc/nginx/nginx.conf ;\
    sed -i 's/:80/:8080/g' /etc/nginx/nginx.conf ;\
    sed -i 's/\(user *nginx\)/#\1/g' /etc/nginx/nginx.conf ;\
    sed -i 's/^pid .*$/pid \/run\/nginx\/nginx.pid;/g' /etc/nginx/nginx.conf ;\
    sed -i "/^http {/a \ proxy_temp_path /tmp/proxy_temp;\n client_body_temp_path /tmp/client_temp;\n fastcgi_temp_path /tmp/fastcgi_temp;\n uwsgi_temp_path /tmp/uwsgi_temp;\n scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf ;\
    sed -i 's@fastcgi_pass.*@fastcgi_pass unix:/var/run/php-fpm/www.sock;@g' /etc/nginx/default.d/php.conf ;\
    rm -f install.yaml 

RUN cp /usr/share/white-pages/conf/config.inc.php /usr/share/white-pages/

USER fusioniam
