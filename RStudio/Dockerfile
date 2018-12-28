FROM rocker/r-ver:3.5.2

ARG RSTUDIO_VERSION
#ENV RSTUDIO_VERSION=${RSTUDIO_VERSION:0.1.463}
ARG S6_VERSION
ENV S6_VERSION=${S6_VERSION:-v1.21.7.0}
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV CONDA_DIR=/opt/conda


ENV PATH=/usr/lib/rstudio-server/bin:$PATH

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    git \
    zlib1g-dev \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    bzip2 \
    psmisc \
    procps \
    python-setuptools \
    sudo \
    wget \
    vim \
    nginx \
    supervisor \
  && unlink /etc/nginx/sites-enabled/default \
  && wget -O libssl1.0.0.deb http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb \
  && dpkg -i libssl1.0.0.deb \
  && rm libssl1.0.0.deb \
  && RSTUDIO_LATEST=$(wget --no-check-certificate -qO- https://s3.amazonaws.com/rstudio-server/current.ver) \
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION=$RSTUDIO_LATEST || true \
  && wget -q http://download2.rstudio.org/rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && dpkg -i rstudio-server-${RSTUDIO_VERSION}-amd64.deb \
  && rm rstudio-server-*-amd64.deb \
  ## Symlink pandoc & standard pandoc templates for use system-wide
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && git clone https://github.com/jgm/pandoc-templates \
  && mkdir -p /opt/pandoc/templates \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  ## RStudio wants an /etc/R, will populate from $R_HOME/etc
  && mkdir -p /etc/R \
  ## Write config files in $R_HOME/etc
  && echo '\n\
    \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
    \n# is not set since a redirect to localhost may not work depending upon \
    \n# where this Docker container is running. \
    \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
    \n  options(httr_oob_default = TRUE) \
    \n}' >> /usr/local/lib/R/etc/Rprofile.site \
  && echo '.libPaths(c("/ride/libraries/r", .libPaths()))' >> /usr/local/lib/R/etc/Rprofile.site \
  && echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron \
  ## Need to configure non-root user for RStudio
  && useradd rstudio \
  && echo "rstudio:rstudio" | chpasswd \
	&& mkdir /home/rstudio \
	&& chown -R rstudio:rstudio /home/rstudio \
	&& addgroup rstudio staff \
  ## Prevent rstudio from deciding to use /usr/bin/R if a user apt-get installs a package
  &&  echo 'rsession-which-r=/usr/local/bin/R' >> /etc/rstudio/rserver.conf \
  ## use more robust file locking to avoid errors when using shared volumes:
  && echo 'lock-type=advisory' >> /etc/rstudio/file-locks \
  ## configure git not to request password each time
  && git config --system credential.helper 'cache --timeout=3600' \
  && git config --system push.default simple 


RUN mkdir -p $CONDA_DIR && \
    chown -R rstudio:rstudio $CONDA_DIR

ENV PATH=$CONDA_DIR/bin:$PATH

ENV MINICONDA_VERSION 4.5.11
RUN cd /tmp && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "e1045ee415162f944b6aebfe560b8fee *Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-${MINICONDA_VERSION}-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda config --system --prepend channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    $CONDA_DIR/bin/conda config --system --set show_channel_urls true && \
    $CONDA_DIR/bin/conda install --quiet --yes conda="${MINICONDA_VERSION%.*}.*" && \
    $CONDA_DIR/bin/conda update --all --quiet --yes && \
    conda clean -tipsy && \
    rm -rf /home/rstudio/.cache/yarn 





COPY install_packages.R /home/rstudio/install_packages.R 
COPY installUtils.R /home/rstudio/installUtils.R

RUN Rscript /home/rstudio/install_packages.R \
  && rm /home/rstudio/install_packages.R \
  && rm /home/rstudio/installUtils.R

COPY ride-proxy /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/ride-proxy /etc/nginx/sites-enabled/ride-proxy
COPY  rserver.conf /etc/rstudio/rserver.conf  
COPY rsession.conf /etc/rstudio/rsession.conf
COPY prepare_start.sh /home/rstudio/prepare_start.sh
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /home/rstudio/.rstudio/monitored/user-settings \
  && echo 'alwaysSaveHistory="0" \
          \nloadRData="0" \
          \nsaveAction="0"' \
          > /home/rstudio/.rstudio/monitored/user-settings/user-settings \
  && chown -R rstudio:rstudio /home/rstudio/.rstudio

COPY userconf.sh /etc/cont-init.d/userconf
RUN mkdir -p /home/rstudio/supervisor /home/rstudio/logs/supervisor

## running with "-e ADD=shiny" adds shiny server
COPY add_shiny.sh /etc/cont-init.d/add
COPY disable_auth_rserver.conf /etc/rstudio/disable_auth_rserver.conf
COPY pam-helper.sh /usr/lib/rstudio-server/bin/pam-helper




ENV RIDE_WD "/ride/work"
RUN mkdir -p $RIDE_WD /ride/work
RUN mkdir -p $RIDE_WD /ride/libraries/r \
  && chown -R rstudio:rstudio /ride


VOLUME $RIDE_WD /ride/libraries
WORKDIR $RIDE_WD


EXPOSE 8080
EXPOSE 8888

# USER rstudio
ENV USER=rstudio
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord_shiny.conf /etc/supervisor/conf.d/supervisord_shiny.conf
ENTRYPOINT ["/usr/bin/supervisord"]

# start container. See 'supervisord.conf'.
CMD ["-c", "/etc/supervisor/conf.d/supervisord.conf"]

