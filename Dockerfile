FROM openjdk:8-buster as build

ENV KAFKA_VERSION="2.5.1"
ENV SCALA_VERSION="2.12"

RUN apt-get update && \
    apt-get install -y curl netcat && \
    apt-get install -y --no-install-recommends git ca-certificates && \
    curl -L https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -o /tmp/kafka_2.12-2.5.1.tgz && \
    echo "91f96f28c016bdaa3fe025f87ace188417a1e594c8e32b7d23a104aa390bc25f5db5897e23cccf00ea7ede3ac20b3028c10363ebe99dcbd7db2cf6237ee7553a  /tmp/kafka_2.12-2.5.1.tgz" | sha512sum -c && \
    tar xf /tmp/kafka_2.12-2.5.1.tgz -C /srv/ && \
    mv /srv/kafka_2.12-2.5.1 /srv/kafka && \
    ln -s $(which jps) /usr/bin/jps
