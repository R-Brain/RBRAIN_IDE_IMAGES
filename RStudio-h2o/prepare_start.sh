
#!/bin/bash
mkdir -p /ride/libraries/r
mkdir -p /ride/work/projects
chown -R rstudio:rstudio /ride/libraries/r 
chown -R rstudio:rstudio /ride/work/projects
sed -i -e "s/sessionId/${RBRAIN_SESSION_ID}\/ride/g" /etc/nginx/nginx.conf
for line in $( cat /etc/environment ) ; do export $line ; done

/etc/init.d/nginx start
sleep 1s
