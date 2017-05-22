FROM centos:7.2.1511
RUN mkdir -p /opt/kafka \
  && cd /opt/kafka \
  && yum -y install java-1.8.0-openjdk-headless  \
  && yum -y install tar \
  && curl -s http://mirrors.aliyun.com/apache/kafka/0.10.2.1/kafka_2.12-0.10.2.1-site-docs.tgz | tar -xz --strip-components=1 \
  && yum -y remove tar \
  && yum clean all 
COPY zookeeper-server-start-multiple.sh /opt/kafka/bin/
RUN chmod -R a=u /opt/kafka
WORKDIR /opt/kafka
EXPOSE 2181 2888 3888 9092
