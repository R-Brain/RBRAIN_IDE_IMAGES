#!/bin/bash
mkdir -p /ride/libraries/r
mkdir -p /ride/work/projects
chown -R rstudio:rstudio /ride/libraries/r 
chown -R rstudio:rstudio /ride/work/projects
sed -i -e "s/sessionId/${RBRAIN_SESSION_ID}\/ride/g" /etc/nginx/nginx.conf

echo "USERNAME=${USERNAME}" >> /etc/environment 
#All RBRAIN Env variables
for line in ${!RBRAIN_*}; do echo $line=${!line} >> /etc/environment; done;
# any variable stats with IEV_
for line in ${!IEV_*}; do echo $line=${!line} >> /etc/environment; done;

cp /etc/environment /home/rstudio/.Renviron

for line in $( cat /etc/environment ) ; do export $line ; done

/etc/init.d/nginx start
sleep 1s



