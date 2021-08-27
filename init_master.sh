#!/bin/bash

# 只在 master 节点执行

# 脚本出错时终止执行
set -e

if [ ${#POD_SUBNET} -eq 0 ] || [ ${#APISERVER_NAME} -eq 0 ]; then
  echo -e "\033[31;1m请确保您已经设置了环境变量 POD_SUBNET 和 APISERVER_NAME \033[0m"
  echo 当前POD_SUBNET=$POD_SUBNET
  echo 当前APISERVER_NAME=$APISERVER_NAME
  exit 1
fi


# 查看完整配置选项 https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
rm -f ./kubeadm-config.yaml
cat <<EOF > ./kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v${1}
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
controlPlaneEndpoint: "${APISERVER_NAME}:6443"
networking:
  serviceSubnet: "10.96.0.0/16"
  podSubnet: "${POD_SUBNET}"
  dnsDomain: "cluster.local"
EOF

# kubeadm init
# 根据您服务器网速的情况，您需要等候 3 - 10 分钟
kubeadm config images pull --config=kubeadm-config.yaml

kubeadm init  --apiserver-advertise-address=${MASTER_IP}  --image-repository registry.aliyuncs.com/google_containers  --kubernetes-version v${1}  --service-cidr=10.2.0.0/16  --pod-network-cidr=${POD_SUBNET}

# 配置 kubectl
rm -rf /root/.kube/
mkdir /root/.kube/
cp -i /etc/kubernetes/admin.conf /root/.kube/config


# 预拉镜像 当然对应的是下面的 flannel 对应的版本，想用最新版的可以 kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# 但是下载最新版的会错误 ，我写了一篇 可以解决  [解决 k8s flannel网络 一直 Init:ImagePullBackOff和coredns状态为Pending](https://blog.csdn.net/qq_22823581/article/details/119932787?spm=1001.2014.3001.5501)

#docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0
#docker pull quay.io/coreos/flannel:v0.14.0

#docker pull registry.cn-beijing.aliyuncs.com/liaosp/flannel:v0.14.0

#docker tag registry.cn-beijing.aliyuncs.com/liaosp/flannel:v0.14.0 quay.io/coreos/flannel:v0.14.0

#docker rmi registry.cn-beijing.aliyuncs.com/liaosp/flannel:v0.14.0  

# 我直接在flannel中已经修改

wget https://files.cnblogs.com/files/liaosp/kube-flannel.json -O ./kube-flannel.yml

kubectl apply -f kube-flannel.yml