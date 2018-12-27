
#!/bin/bash
sed -i -e "s/sessionId/${RBRAIN_SESSION_ID}\/ride/g" /etc/nginx/nginx.conf
for line in $( cat /etc/environment ) ; do export $line ; done

/etc/init.d/nginx start
sleep 1s

