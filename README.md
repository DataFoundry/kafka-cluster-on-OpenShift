# 本文引用[ jim-minter/kafkanetes](https://github.com/jim-minter/kafkanetes),对部分内容进行了更改。
* 1 更新了Dockerfile，替换了原本引用的REHL镜像，解决build失败的问题
* 2 更新了kafkanetes-deploy-kafka-2.yaml，更改了mount点，我们使用的环境使用heketi管理glusterFS，如果直接在挂载在/tmp/kafka-logs下，hekete管理的glusterFS集群下会默认的在挂载目录创建一个.trashcan目录，kafka会认为这也是个topic日志目录就会冲突。
# "Kafkanetes"

Run [Apache Kafka](https://kafka.apache.org/) and [Apache ZooKeeper](https://zookeeper.apache.org/) on [OpenShift v3](https://www.openshift.com/).

Proof of concept; builds following architectures:

* 1 ZooKeeper pod <-> 1 Kafka pod
* 1 ZooKeeper pod <-> 2 Kafka pods
* 3 ZooKeeper pods <-> 1 Kafka pod
* 3 ZooKeeper pods <-> 2 Kafka pods

Jim Minter, 24/03/2016

## Quick start

Prerequirement: ensure you have persistent storage available in OpenShift.  If not, read [Configuring Persistent Storage](https://docs.openshift.com/enterprise/latest/install_config/persistent_storage/index.html).

1. Clone repository
 ```bash
$ git clone https://github.com/wfw2046/kafka-cluster-on-OpenShift.git
```

1.  import templates into OpenShift 
   ```bash
$ for i in kafka-cluster-on-OpenShift/*.yaml; do sudo oc create -f $i ; done
```

1. Build the Kafkanetes image, containing CentOs, Java, Kafka and its distribution of Zookeeper
   ```bash
$ oc new-app kafkanetes-build
$ oc logs --follow build/kafkanetes-1
```

1. Deploy 3-pod Zookeeper
   ```bash
$ oc new-app kafkanetes-deploy-zk-3
```

1. Deploy 2-pod Kafka
   ```bash
$ oc new-app kafkanetes-deploy-kafka-2
```

## Follow the [Apache Kafka Documentation Quick Start](https://kafka.apache.org/documentation.html#quickstart)

1. Deploy a debugging container and connect to it
   ```bash
$ oc new-app kafkanetes-debug
$ oc rsh $(oc get pods -l deploymentconfig=kafkanetes-debug --template '{{range .items}}{{.metadata.name}}{{end}}')
```

1. Create a topic
   ```bash
bash-4.2$ bin/kafka-topics.sh --create --zookeeper kafkanetes-zk:2181 --replication-factor 1 --partitions 1 --topic test
```

1. List topics
   ```bash
bash-4.2$ bin/kafka-topics.sh --list --zookeeper kafkanetes-zk:2181
```

1. Send some messages
   ```bash
bash-4.2$ bin/kafka-console-producer.sh --broker-list kafkanetes-kafka:9092 --topic test 
foo
bar 
baz
^D
```

1. Receive some messages
   ```bash
bash-4.2$ bin/kafka-console-consumer.sh --zookeeper kafkanetes-zk:2181 --topic test --from-beginning
```

## Notes

* Known issue: with this setup, Kafka advertises itself using a non-qualified domain name, which means that it can only be accessed by clients in the same namespace.  Further customisation to changed the announced domain name/port and/or use NodePorts to enable external access should be fairly straightforward.

* The forthcoming Kubernetes ["Pet Set"](https://github.com/kubernetes/kubernetes/pull/18016) functionality should help normalise the templates for 3-pod ZooKeeper and 2-pod Kafka.
