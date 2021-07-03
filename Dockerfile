FROM apache/airflow

USER root

RUN apt-get update \
    && apt-get -qy install -y --no-install-recommends \
        unzip \
        libaio1 \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup Oracle client
RUN mkdir /opt/oracle
COPY files/instantclient-basic-linux.x64-19.10.0.0.0dbru.zip /opt/oracle
RUN cd /opt/oracle && \
    unzip instantclient-basic-linux.x64-19.10.0.0.0dbru.zip && \
    sh -c "echo /opt/oracle/instantclient_19_10 > /etc/ld.so.conf.d/oracle-instantclient.conf" && \
    ldconfig
RUN export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_10:${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
RUN rm /opt/oracle/instantclient-basic-linux.x64-19.10.0.0.0dbru.zip

USER ${AIRFLOW_UID}

RUN pip3 install \
    redis \
    flower \
    apache-airflow-providers-oracle \
    apache-airflow-providers-slack \
    pylint-airflow \
    pylint \
    pytest

RUN airflow info