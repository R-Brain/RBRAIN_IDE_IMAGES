FROM jupyter/tensorflow-notebook:7f1482f5a136

ARG NB_USER="jovyan"

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends vim nginx supervisor \
    && unlink /etc/nginx/sites-enabled/default
 
COPY ride-proxy /etc/nginx/sites-available/
RUN sudo ln -s /etc/nginx/sites-available/ride-proxy /etc/nginx/sites-enabled/ride-proxy

COPY jupyter_notebook_config.py /etc/jupyter/
RUN sudo chown -R $NB_USER:users $HOME
ENV RIDE_WD "/ride/work"

COPY start.sh /usr/local/bin/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord_shiny.conf /etc/supervisor/conf.d/supervisord_shiny.conf


RUN sudo mkdir -p $RIDE_WD /ride/libraries \
  && sudo chown -R $NB_USER:users /ride 

RUN sudo echo "$NB_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $NB_USER

RUN mkdir -p $HOME/ride $HOME/supervisor $HOME/logs/supervisor
VOLUME $RIDE_WD /ride/libraries
WORKDIR $RIDE_WD

ENV PYTHONUSERBASE "/ride/libraries/py"
ENV PATH="${PYTHONUSERBASE}/bin:${PATH}"
ENV CONDA_ENVS_PATH="/ride/libraries/conda/envs:/opt/conda/envs"

EXPOSE 8080

COPY pydistutils.cfg $HOME/.pydistutils.cfg
RUN mkdir -p $HOME/ride

ENTRYPOINT ["/usr/bin/supervisord"]
# start container. See 'supervisord.conf'.
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]


