## 修改机器名字和hosts
`hostnamectl set-hostname master`

`hostnamectl status`

`echo "192.168.205.31   $(hostname)" >> /etc/hosts`


> 执行 `./base_install.sh 1.19.5`

export MASTER_IP=192.168.205.31

这个APISERVER_NAME可以是外网可以访问的

`export APISERVER_NAME=192.168.205.31`

> 创建网段
export POD_SUBNET=10.100.0.1/16

echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts

```

 ## 执行 `./init_master.sh 1.19.5`


```
# 只在 master 节点执行
# 执行如下命令，等待 3-10 分钟，直到所有的容器组处于 Running 状态
watch kubectl get pod -n kube-system -o wide

# 查看 master 节点初始化结果
kubectl get nodes -o wide 
```


## Step 5 ：初始化 Worker 节点
### 5.1 ： 首先在 Master 节点上执行以下命令
```
# 只在 master 节点执行
kubeadm token create --print-join-command

```
可获取kubeadm join 命令及参数，如下所示
```
# kubeadm token create 命令的输出，形如：
kubeadm join apiserver.luckyhomemart.com:6443 --token o5vmo9.bazxuhkyew9rajvi     --discovery-token-ca-cert-hash sha256:956583e510265cb6ec4bd5f11f36a05917e822aa7e3fbf950bce0e6d732ad956 

```
>该 token 的有效时间为 2 个小时，2小时内，您可以使用此 token 初始化任意数量的 worker 节点。

### 5.2 : 初始化 worker （只在worker 节点执行）
 
```
# 只在 worker 节点执行
# 替换 x.x.x.x 为 master 节点的内网 IP
# export 命令只在当前 shell 会话中有效，开启新的 shell 窗口后，如果要继续安装过程，请重新执行此处的 export 命令
export MASTER_IP=x.x.x.x
# 替换 apiserver.luckyhomemart.com 为 您想要的 dnsName  用在加入时候的寻找的地址，也可以是域名
export APISERVER_NAME=192.168.205.31
echo "${MASTER_IP}    ${APISERVER_NAME}" >> /etc/hosts
```

### 5.4 : 执行 Master 节点上 token 信息加入集群
```
# 替换为 master 节点上 kubeadm token create 命令的输出
kubeadm join apiserver.luckyhomemart.com:6443 --token o5vmo9.bazxuhkyew9rajvi     --discovery-token-ca-cert-hash sha256:956583e510265cb6ec4bd5f11f36a05917e822aa7e3fbf950bce0e6d732ad956 

```
           
### 5.5 :检查初始化结果
在 master 节点上执行（只在Master上）
`kubectl get nodes -o wide`
