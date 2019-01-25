FROM jupyter/datascience-notebook:87210526f381

ARG NB_USER="jovyan"

USER root
COPY jupyter_notebook_config.py /etc/jupyter/
RUN sudo chown -R $NB_USER:users $HOME
ENV RIDE_WD "/ride/work"

COPY start.sh /usr/local/bin/

RUN sudo mkdir -p $RIDE_WD /ride/libraries \
  && sudo chown -R $NB_USER:users /ride 

USER $NB_USER

VOLUME $RIDE_WD /ride/libraries
WORKDIR $RIDE_WD

ENV PYTHONUSERBASE "/ride/libraries/py"
ENV PATH="${PYTHONUSERBASE}/bin:${PATH}"
ENV CONDA_ENVS_PATH="/ride/libraries/conda/envs:/opt/conda/envs"

EXPOSE 8080

COPY pydistutils.cfg $HOME/.pydistutils.cfg
RUN mkdir -p $HOME/ride




