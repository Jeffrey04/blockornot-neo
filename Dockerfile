FROM python:3-stretch

ENV APP_PORT=80
ENV APP_DB=/var/lib/blockornot
ENV APP_ANALYTICS=foo

RUN \
    pip install bottle ujson requests && \
    mkdir /opt/blockornot && \
    mkdir /var/lib/blockornot && \
    mkdir /var/lib/blockornot-cert

COPY ./blockornot /opt/blockornot

WORKDIR /opt/blockornot

CMD ["python3", "./bin/index.py"]