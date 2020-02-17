---
Title: 测试题作答
---

#### Task 0: Install a ubuntu 16.04 server 64-bit

**0.1**.  基础信息收集(OS版本、内核、用户、IP信息)

``` elixir
admin1@demo:~$ sudo lsb_release -a      #OS版本
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 16.04.6 LTS
Release:        16.04
Codename:       xenial
admin1@demo:~$ sudo uname -rs           #内核版本
Linux 4.4.0-142-generic
admin1@demo:~$ sudo id admin1           #admin1为创建的普通用户
uid=1000(admin1) gid=1000(admin1) groups=1000(admin1),4(adm),24(cdrom),27(sudo),30(dip),46(plugdev),110(lxd),115(lpadmin),116(sambashare)
admin1@demo:~$ sudo id root             #root为管理员
uid=0(root) gid=0(root) groups=0(root)
admin1@demo:~$ sudo ip addr|sed -nr 's#^.*inet (.*)/24.*$#\1#gp'          #使用NAT网络，自动获取的IP地址
192.168.114.128
```

 **0.2**.  修改ssh服务端口号(可使用root用户修改)

``` elixir
admin1@demo:~$ sudo grep -rn "Port " /etc/ssh/sshd_config
5:Port 22
admin1@demo:~$ sudo cp -a /etc/ssh/sshd_config{,.bak-`date +%F`}
admin1@demo:~$ sudo sed -i 's/\(Port \)22/\12222/' /etc/ssh/sshd_config
admin1@demo:~$ sudo systemctl restart sshd
admin1@demo:~$ sudo ss -lntup |grep sshd
tcp    LISTEN     0      128       *:2222                  *:*                   users:(("sshd",pid=1153,fd=3))
tcp    LISTEN     0      128      :::2222                 :::*                   users:(("sshd",pid=1153,fd=4))
```

#### Task 1: Update system

**1.1**.  使用ssh远程登录访问测试

``` elixir
$ ssh admin1@192.168.114.128 -p 2222
The authenticity of host '[192.168.114.128]:2222 ([192.168.114.128]:2222)' can't be established.
ECDSA key fingerprint is SHA256:GAtRi5i7a6/lapl06KwRGMMVEW/Ozc1CQxvKxaH/738.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[192.168.114.128]:2222' (ECDSA) to the list of known hosts.
admin1@192.168.114.128's password:
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.4.0-142-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

152 packages can be updated.
103 updates are security updates.

New release '18.04.3 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Thu Feb 14 19:36:18 2020 from 192.168.114.128
admin1@demo:~$
```

**1.2**. 系统及软件升级(admin1用户)

**Step 1：**  更换国内镜像源

 - 本实验使用清华源：http://mirrors.tuna.tsinghua.edu.cn/ubuntu/

**Step 2：**  执行如下系统升级步骤

``` elixir
admin1@demo:~$ sudo apt update
admin1@demo:~$ sudo apt dist-upgrade
admin1@demo:~$ sudo apt autoremove
admin1@demo:~$ sudo apt-get install update-manager-core
admin1@demo:~$ sudo nano /etc/update-manager/release-upgrades    #确保update-manager行设置为lts
admin1@demo:~$ sudo do-release-upgrade -c
admin1@demo:~$ sudo reboot
admin1@demo:~$ sudo do-release-upgrade
```

**Step 3：**  操作系统升级结果验证

``` elixir
admin1@demo:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 18.04.4 LTS
Release:        18.04
Codename:       bionic
admin1@demo:~$ uname -rs
Linux 4.15.0-76-generic
```

**1.3**. 内核升级

 - 本次内核升级以5.3.18 mainline build为例，升级步骤如下：

``` elixir
admin1@demo:~$ sudo uname -rs       #内核升级前版本为4.15.0
Linux 4.15.0-76-generic
admin1@demo:~$ wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.18/linux-headers-5.3.18-050318_5.3.18-050318.201912181133_all.deb
admin1@demo:~$ wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.18/linux-headers-5.3.18-050318-generic_5.3.18-050318.201912181133_amd64.deb
admin1@demo:~$ wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.18/linux-image-unsigned-5.3.18-050318-generic_5.3.18-050318.201912181133_amd64.deb
admin1@demo:~$ wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.3.18/linux-modules-5.3.18-050318-generic_5.3.18-050318.201912181133_amd64.deb
admin1@demo:~$ sha1sum *.deb
4d391161651669b701828d3692d424f896f21a22  linux-headers-5.3.18-050318_5.3.18-050318.201912181133_all.deb
c1d9212be72289c94a341cdcdadc185e3c7ff8bb  linux-headers-5.3.18-050318-generic_5.3.18-050318.201912181133_amd64.deb
8d3a65b0c17bc9112f7a87b6c2586b53d114e7fe  linux-image-unsigned-5.3.18-050318-generic_5.3.18-050318.201912181133_amd64.deb
4c198aabc97502c40105a27b65fc8462c93e2d35  linux-modules-5.3.18-050318-generic_5.3.18-050318.201912181133_amd64.deb
admin1@demo:~$ sudo dpkg -i *.deb
admin1@demo:~$ sudo reboot
admin1@demo:~$ sudo uname -rs       #内核升级后版本为5.3.18
Linux 5.3.18-050318-generic
```

#### Task 2: install gitlab-ce version in the host

**Step 1:**  安装并配置必要的依赖关系

``` elixir
admin1@demo:~$ sudo apt-get update
admin1@demo:~$ sudo apt-get install -y curl openssh-server ca-certificates
admin1@demo:~$ sudo apt-get install -y postfix 
```

**Step 2:**  添加GitLab软件包镜像库

``` elixir
admin1@demo:~$ sudo curl https://packages.gitlab.com/gpg.key 2> /dev/null | sudo apt-key add - &>/dev/null
admin1@demo:~$ sudo vim /etc/apt/sources.list.d/gitlab-ce.list
文件添加如下内容：
deb https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu xenial main
```

**Step 3:** 安装、配置及服务启动

``` elixir
admin1@demo:~$ sudo apt-get update          
admin1@demo:~$ sudo apt-get install gitlab-ce	#安装gitlab-ce
admin1@demo:~$ sudo gitlab-ctl reconfigure		#执行配置
admin1@demo:~$ sudo gitlab-ctl status			#查看运行状态
run: alertmanager: (pid 19252) 109s; run: log: (pid 18759) 212s
run: gitaly: (pid 19180) 113s; run: log: (pid 18188) 350s
run: gitlab-exporter: (pid 19202) 112s; run: log: (pid 18692) 228s
run: gitlab-workhorse: (pid 19163) 113s; run: log: (pid 18588) 254s
run: grafana: (pid 19278) 108s; run: log: (pid 19052) 143s
run: logrotate: (pid 18623) 243s; run: log: (pid 18634) 242s
run: nginx: (pid 18600) 250s; run: log: (pid 18614) 247s
run: node-exporter: (pid 19173) 113s; run: log: (pid 18666) 236s
run: postgres-exporter: (pid 19268) 109s; run: log: (pid 18781) 206s
run: postgresql: (pid 18333) 344s; run: log: (pid 18354) 341s
run: prometheus: (pid 19221) 111s; run: log: (pid 18735) 218s
run: redis: (pid 18142) 357s; run: log: (pid 18153) 356s
run: redis-exporter: (pid 19205) 112s; run: log: (pid 18711) 224s
run: sidekiq: (pid 18560) 262s; run: log: (pid 18573) 259s
run: unicorn: (pid 18530) 268s; run: log: (pid 18552) 265s
```
**Step 4:**  修改gitlab的端口和地址

``` elixir
admin1@demo:~$ sudo cp -a /etc/gitlab/gitlab.rb{,.bak-`date +%F`}
admin1@demo:~$ sudo vim /etc/gitlab/gitlab.rb	#修改配置文件
修改external_url数据：external_url 'http://gitlab.example.com'，比如说修改为：external_url 'http://127.0.0.1:8080'其中也可修改为gitlab虚拟主机的IP，端口修改为8080
dmin1@demo:~$ sudo grep -vE "^$|#" /etc/gitlab/gitlab.rb	 #确认是否修改成功              
external_url 'http://localhost:8080'
unicorn['port'] = 8888
admin1@demo:~$ sudo gitlab-ctl reconfigure		#刷新配置
admin1@demo:~$ sudo gitlab-ctl restart			#重启服务
admin1@demo:~$ sudo lsof -i:8080				#查看端口
COMMAND  PID       USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
nginx   7046       root    7u  IPv4 116621      0t0  TCP *:http-alt (LISTEN)
nginx   7048 gitlab-www    7u  IPv4 116621      0t0  TCP *:http-alt (LISTEN)
```

**Step 5:** 本地访问测试

 - 虚拟主机本地浏览器访问：http://127.0.0.1:8080，登录情况如下：

![图1 登录页面](https://github.com/jerome521/go-web-hello-world/blob/master/img/1.png)

#### Task 3: create a demo group/project in gitlab

**Step1:** 在本地gitlab创建demo组和go-web-hello-world项目，访问测试如下图所示：

![图2 组和项目验证一](https://github.com/jerome521/go-web-hello-world/blob/master/img/2.png)

![图3 组和项目验证二](https://github.com/jerome521/go-web-hello-world/blob/master/img/3.png)

**Step 2:** 提交代码测试(以README.md为例)

``` elixir
admin1@demo:~$ git clone ssh://git@localhost:2222/demo/go-web-hello-world.git
admin1@demo:~$ cd go-web-hello-world/
admin1@demo:~$ vim README.md 
admin1@demo:~$ git status
admin1@demo:~$ git add README.md 
admin1@demo:~$ git commit -m "add README"
admin1@demo:~$ git push -u origin master
```

#### Task 4: build the app and expose ($ go run) the service to 8081 port

**Step 1:** 创建一个go应用程序

 - 应用页面展现“Go Web Hello World!”，服务端口为8081，实现如下：

``` golang
package main

import (
    "fmt"
    "net/http"
)

func handler(writer http.ResponseWriter, request *http.Request) {
    fmt.Fprintf(writer, "Go Web Hello World %s!", request.URL.Path[1:])
}

func main() {
    http.HandleFunc("/", handler)
    http.ListenAndServe(":8081", nil)
}
```
**Step 2:** 部署服务，并测试验证

 - 命令行验证如下：

``` elixir
admin1@demo:~/go-web-hello-world$ go build -o main main.go
admin1@demo:~/go-web-hello-world$ go run main.go		#编译运行命令
admin1@demo:~$ ss -lntup|grep 8081       
tcp    LISTEN   0        1024                    *:8081                 *:*      users:(("main",pid=43369,fd=3)) 
admin1@demo:~$ curl http://127.0.0.1:8081				#测试验证
Go Web Hello World !
```

 - 浏览器访问验证，如下图所示：

![图4 应用页面访问验证](https://github.com/jerome521/go-web-hello-world/blob/master/img/4.png)

#### Task 5: install docker

**Step 1:** 卸载旧版本、安装依赖包

``` elixir
admin1@demo:~$ sudo apt-get remove docker.io docker-engine
admin1@demo:~$ sudo apt-get update
admin1@demo:~$ sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```

**Step 2:** 添加Docker的GPG密钥及软件源(本例安装清华源)

``` elixir
admin1@demo:~$ curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
admin1@demo:~$ sudo apt-key fingerprint 0EBFCD88
admin1@demo:~$ sudo add-apt-repository "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"  
```

**Step 3:** 安装docker-ce及普通用户授权

``` elixir
admin1@demo:~$ sudo apt-get updat
admin1@demo:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io
admin1@demo:~$ sudo usermod -aG docker admin1
```

**Step 4:** 更换docker hub的国内镜像源

``` elixir
admin1@demo:~$ sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://1nj0zren.mirror.aliyuncs.com",
        "https://docker.mirrors.ustc.edu.cn",
        "http://f1361db2.m.daocloud.io",
        "https://registry.docker-cn.com"
    ]
}
EOF
```

**Step 5:** 服务相关操作及验证

``` elixir
admin1@demo:~$ sudo systemctl daemon-reload
admin1@demo:~$ sudo systemctl restart docker
admin1@demo:~$ sudo systemctl enable docker 
admin1@demo:~$ sudo systemctl status docker
admin1@demo:~$ sudo docker version
Client: Docker Engine - Community
 Version:           19.03.5
 API version:       1.40
 Go version:        go1.12.12
 Git commit:        633a0ea838
 Built:             Wed Nov 13 07:29:52 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.5
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.12
  Git commit:       633a0ea838
  Built:            Wed Nov 13 07:28:22 2019
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.10
  GitCommit:        b34a5c8af56e510852c35414db4c1f4fa6172339
 runc:
  Version:          1.0.0-rc8+dev
  GitCommit:        3e425f80a8c931f88e6d94a8c831b9d5aa481657
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

#### Task 6: run the app in container

**Step 1:** 编写Dockerfile，并构建测试

``` elixir
admin1@demo:~/go-web-hello-world$ sudo vim Dockerfile
FROM golang:latest
MAINTAINER Jerome <haodima521@126.com>
WORKDIR /
ADD main /
ENV PORT 8081
EXPOSE 8082
ENTRYPOINT ["./main"]
admin1@demo:~/go-web-hello-world$ sudo docker build -t webapp:v1 .      
Sending build context to Docker daemon   9.53MB
Step 1/7 : FROM golang:latest
 ---> 297e5bf50f50
Step 2/7 : MAINTAINER Jerome <haodima521@126.com>
 ---> Running in 6123b090d90f
Removing intermediate container 6123b090d90f
 ---> cdeac1a958be
Step 3/7 : WORKDIR /
 ---> Running in d4f2f9d056aa
Removing intermediate container d4f2f9d056aa
 ---> 262169c449a2
Step 4/7 : ADD main /
 ---> ab5b816671c1
Step 5/7 : ENV PORT 8081
 ---> Running in 05666b25ce47
Removing intermediate container 05666b25ce47
 ---> e9254982f27b
Step 6/7 : EXPOSE 8082
 ---> Running in b13a354f2fdc
Removing intermediate container b13a354f2fdc
 ---> 28935e60ac97
Step 7/7 : ENTRYPOINT ["./main"]
 ---> Running in 0b8ae3c1f388
Removing intermediate container 0b8ae3c1f388
 ---> 1948ff79bbb4
Successfully built 1948ff79bbb4
Successfully tagged webapp:v1
admin1@demo:~/go-web-hello-world$ sudo docker image ls            
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
webapp              v1                  1948ff79bbb4        6 seconds ago       809MB
golang              latest              297e5bf50f50        2 days ago          803MB
```

**Step 2:** 使用Docker发布应用，并验证

``` elixir
admin1@demo:~/go-web-hello-world$ docker run -p 8082:8081 --name="go-web" --rm -idt webapp:v1           
0604814424a16555cea29522b3ec20d7f258f69c73cd8180fd4969ede20a39d0
admin1@demo:~/go-web-hello-world$ sudo docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                              NAMES
0604814424a1        webapp:v1           "./main"            2 seconds ago       Up 1 second         8082/tcp, 0.0.0.0:8082->8081/tcp   go-web
admin1@demo:~/go-web-hello-world$ sudo ss -lntup|grep 8082
tcp    LISTEN   0        1024                    *:8082                 *:*      users:(("docker-proxy",pid=19317,fd=4))                     
admin1@demo:~/go-web-hello-world$ curl http://127.0.0.1:8082
Go Web Hello World !
```

 - 浏览器访问验证，如下图示：

![图5 容器发布应用验证](https://github.com/jerome521/go-web-hello-world/blob/master/img/5.png)

#### Task 7: push image to dockerhub

**Step 1:** 注册Docker Hub，并登录验证

``` elixir
admin1@demo:~/go-web-hello-world$ sudo docker login --username=jerome521
Password: 
WARNING! Your password will be stored unencrypted in /home/admin1/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
admin1@demo:~/go-web-hello-world$ sudo docker info|grep Username
WARNING: No swap limit support
 Username: jerome521
```

 **Step 2:** 根据创建的容器、提交新镜像，并上传镜像至Docker Hub
 
``` elixir
admin1@demo:~/go-web-hello-world$ sudo docker container ls -all         
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                              NAMES
0604814424a1        webapp:v1           "./main"            About an hour ago   Up About an hour    8082/tcp, 0.0.0.0:8082->8081/tcp   go-web

 admin1@demo:~/go-web-hello-world$ sudo docker commit -m "go-web-hello-world" -a "Jerome" 0604814424a1 jerome521/go-web-hello-world:v0.1     
sha256:4ea99eade0aa0582a46ddf8da0b034f5cda26c506689eba16e5d4909662cb67c
admin1@demo:~/go-web-hello-world$ sudo docker image ls
REPOSITORY                     TAG                 IMAGE ID            CREATED             SIZE
jerome521/go-web-hello-world   v0.1                4ea99eade0aa        5 seconds ago       809MB
webapp                         v1                  1948ff79bbb4        2 hours ago         809MB
golang                         latest              297e5bf50f50        2 days ago          803MB
admin1@demo:~/go-web-hello-world$ sudo docker push jerome521/go-web-hello-world:v0.1
The push refers to repository [docker.io/jerome521/go-web-hello-world]
c5defd452382: Pushed 
cae11887bc90: Mounted from library/golang 
729c3ac48990: Mounted from library/golang 
8378cd889737: Mounted from library/golang 
5c813a85f7f0: Mounted from library/golang 
bdca38f94ff0: Pushed 
faac394a1ad3: Mounted from library/golang 
ce8168f12337: Pushed 
v0.1: digest: sha256:8ccc72e1ffe7f4ba8f0c368b7223ea5bab18297460401f650066ed28c651f5e3 size: 2006
```

 - 登录Docker Hub验证镜像上传是否成功，如下图所示：

![图6 Docker Hub上传镜像验证](https://github.com/jerome521/go-web-hello-world/blob/master/img/6.png)

#### Task 8: document the procedure in a MarkDown file

 - Task (0-7) 技术实现详细步骤请参考本文

#### Task 9: install a single node Kubernetes cluster using kubeadm

 - 本章节部署内容，以root用户执行

**Step 1:** 添加相应的源

``` elixir
root@demo:~# apt-get update && apt-get install -y apt-transport-https
root@demo:~# curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   659  100   659    0     0   4513      0 --:--:-- --:--:-- --:--:--  4513
OK
root@demo:~# cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
> deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
> EOF
```

**Step 2:** 下载Docker & Kubeadm & Kubelet & Kubernetes-cni

``` elixir
root@demo:~# apt-get update
Hit:1 http://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic InRelease
Get:2 http://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-updates InRelease [88.7 kB]                                                 
Get:3 https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial InRelease [8,993 B]                                                              
Get:4 https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu bionic InRelease [64.4 kB]                                                       
Ign:5 http://dl.google.com/linux/chrome/deb stable InRelease                                  
Get:6 http://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-backports InRelease [74.6 kB]         
Get:7 http://mirrors.tuna.tsinghua.edu.cn/ubuntu bionic-security InRelease [88.7 kB]                                  
Hit:8 https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/ubuntu xenial InRelease                              
Hit:9 http://dl.google.com/linux/chrome/deb stable Release                                                
Ign:10 https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial/main amd64 Packages
Get:10 https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial/main amd64 Packages [33.9 kB]
Get:11 https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu bionic/stable amd64 Packages [10.3 kB]
Fetched 370 kB in 2s (241 kB/s)                                 
Reading package lists... Done
root@demo:~# sudo apt-get install -y kubelet kubernetes-cni=0.7.5-00 kubeadm
```

**Step 3:** 关闭swap

 - 注释掉/etc/fstab下swap挂载，如下所示：

``` elixir
root@demo:~# grep "swap" /etc/fstab
#swap was on /dev/sda5 during installation
#UUID=04484f16-e27e-4a7c-a8dd-7011e65165a7 none            swap    sw              0       0
```

**Step 4:** 获取K8S组件镜像列表，编写脚本脚本批次pull该列表

``` elixir
root@demo:~# kubeadm config images list
k8s.gcr.io/kube-apiserver:v1.17.3
k8s.gcr.io/kube-controller-manager:v1.17.3
k8s.gcr.io/kube-scheduler:v1.17.3
k8s.gcr.io/kube-proxy:v1.17.3
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.4.3-0
k8s.gcr.io/coredns:1.6.5
root@demo:~# more k8s_script.sh    
#! /bin/bash
images=(
    kube-apiserver:v1.17.3
    kube-controller-manager:v1.17.3
    kube-scheduler:v1.17.3
    kube-proxy:v1.17.3
    pause:3.1
    etcd:3.4.3-0
    coredns:1.6.5
)
 
for imageName in ${images[@]} ; do
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName  k8s.gcr.io/$imageName
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
root@demo:~# chmod +x k8s_script.sh 
root@demo:~# ./k8s_script.sh 
root@demo:~# docker image ls
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
jerome521/go-web-hello-world         v0.1                0d954665d0ff        11 hours ago        809MB
webapp                               v1                  1948ff79bbb4        13 hours ago        809MB
golang                               latest              297e5bf50f50        2 days ago          803MB
k8s.gcr.io/kube-proxy                v1.17.3             ae853e93800d        5 days ago          116MB
k8s.gcr.io/kube-controller-manager   v1.17.3             b0f1517c1f4b        5 days ago          161MB
k8s.gcr.io/kube-apiserver            v1.17.3             90d27391b780        5 days ago          171MB
k8s.gcr.io/kube-scheduler            v1.17.3             d109c0821a2b        5 days ago          94.4MB
k8s.gcr.io/coredns                   1.6.5               70f311871ae1        3 months ago        41.6MB
k8s.gcr.io/etcd                      3.4.3-0             303ce5db0e90        3 months ago        288MB
k8s.gcr.io/pause                     3.1                 da86e6ba6ca1        2 years ago         742kB
```

**Step 5:** 初始化环境及配置授权信息

``` elixir
root@demo:~# kubeadm init --ignore-preflight-errors=Swap --pod-network-cidr=10.244.0.0/16
......省略
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.114.128:6443 --token o4e1so.li5p7wialc6g3qmq \
    --discovery-token-ca-cert-hash sha256:e1bc585208e73d80da9f2658ab8a337c9e3698562e25b275ee4893d9c44079cf
root@demo:~# mkdir -p $HOME/.kube
root@demo:~# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
root@demo:~# sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**Step 6:** 单节点，设置master节点也可以运行Pod

 - kubernetes官方默认策略是worker节点运行Pod，master节点不运行Pod。如果只是为了开发或者其他目的而需要部署单节点集群，可以通过以下的命令设置：

``` elixir
root@demo:~# kubectl taint nodes --all node-role.kubernetes.io/master-
node/demo untainted
root@demo:~# kubectl get pods -n kube-system
NAME                           READY   STATUS    RESTARTS   AGE
coredns-6955765f44-qxq5j       0/1     Pending   0          9m29s
coredns-6955765f44-rt2ns       0/1     Pending   0          9m29s
etcd-demo                      1/1     Running   0          9m38s
kube-apiserver-demo            1/1     Running   0          9m38s
kube-controller-manager-demo   1/1     Running   0          9m38s
kube-proxy-sq4ql               1/1     Running   0          9m29s
kube-scheduler-demo            1/1     Running   0          9m38s
root@demo:~# kubectl get nodes
NAME   STATUS     ROLES    AGE     VERSION
demo   NotReady   master   9m59s   v1.17.3
```

**Step 7:** 添加flannel网络插件

``` elixir
root@demo:~# mkdir -p ~/k8s/
root@demo:~# cd ~/k8s/
root@demo:~/k8s# curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
root@demo:~/k8s# kubectl apply -f kube-flannel.yml
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds-amd64 created
daemonset.apps/kube-flannel-ds-arm64 created
daemonset.apps/kube-flannel-ds-arm created
daemonset.apps/kube-flannel-ds-ppc64le created
daemonset.apps/kube-flannel-ds-s390x created
root@demo:~/k8s# kubectl get pods -n kube-system
NAME                           READY   STATUS    RESTARTS   AGE
coredns-6955765f44-qxq5j       1/1     Running   0          12m
coredns-6955765f44-rt2ns       1/1     Running   0          12m
etcd-demo                      1/1     Running   0          12m
kube-apiserver-demo            1/1     Running   0          12m
kube-controller-manager-demo   1/1     Running   0          12m
kube-flannel-ds-amd64-jr4mr    1/1     Running   0          50s
kube-proxy-sq4ql               1/1     Running   0          12m
kube-scheduler-demo            1/1     Running   0          12m
```

**Step 8:** K8S组件部署验证

``` elixir
root@demo:~# kubectl get pods -n kube-system
NAME                           READY   STATUS    RESTARTS   AGE
coredns-6955765f44-qxq5j       1/1     Running   0          17m
coredns-6955765f44-rt2ns       1/1     Running   0          17m
etcd-demo                      1/1     Running   0          17m
kube-apiserver-demo            1/1     Running   0          17m
kube-controller-manager-demo   1/1     Running   0          17m
kube-flannel-ds-amd64-jr4mr    1/1     Running   0          6m17s
kube-proxy-sq4ql               1/1     Running   0          17m
kube-scheduler-demo            1/1     Running   0          17m
root@demo:~# kubectl get svc  
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   17m
root@demo:~# kubectl get nodes
NAME   STATUS   ROLES    AGE   VERSION
demo   Ready    master   18m   v1.17.3
root@demo:~# kubectl get pods 
No resources found in default namespace.
```

#### Task 10: deploy the hello world container

**Step 1:** 编写部署go应用程序的YAML文件

``` yaml
root@demo:~/k8s# more go-web.yaml            
apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: go-web
spec:
  selector:
    matchLabels:
      app: go-web
  replicas: 1 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: go-web
    spec:
      containers:
      - name: go-web
        image: jerome521/go-web-hello-world:v0.1
        ports:
        - containerPort: 8081
          protocol: TCP
root@demo:~/k8s# more go-web-service.yaml    
apiVersion: v1
kind: Service
metadata:
  name: go-web
  labels:
    app: go-web
spec:
  type: NodePort
  ports:
  - port: 8081
    targetPort: 8081
    nodePort: 31080
    protocol: TCP
  selector:
    app: go-web
```

**Step 2:** 服务部署验证测试

``` elixir
root@demo:~/k8s# kubectl apply -f go-web.yaml
deployment.apps/go-web created
root@demo:~/k8s# kubectl apply -f go-web-service.yaml
service/go-web created
root@demo:~/k8s# kubectl get pods -o wide
NAME                      READY   STATUS    RESTARTS   AGE   IP           NODE   NOMINATED NODE   READINESS GATES
go-web-697d8dc468-thrbj   1/1     Running   0          35s   10.244.0.5   demo   <none>           <none>
root@demo:~/k8s# kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
go-web       NodePort    10.102.203.56   <none>        8081:31080/TCP   31s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP          23m
root@demo:~/k8s# ss -lntup |grep 31080
tcp   LISTEN  0        1024                      *:31080                *:*      users:(("kube-proxy",pid=9621,fd=10)) 
root@demo:~/k8s# curl http://127.0.0.1:31080
Go Web Hello World !
```

#### Task 11: install kubernetes dashboard

**Step 1:** 通过YAML部署dashboard，并暴露31081服务端口

``` elixir
root@demo:~/k8s# wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
root@demo:~/k8s# mv recommended.yaml kubernetes-dashboard.yaml
#在YAML中Dashboard Service 部分的spec语句块，新增内容如下：
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 31081
      protocol: TCP
#为便于部署建议提前从阿里云获取所需dashboard镜像，操作如下：
root@demo:~/k8s# docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1
v1.10.1: Pulling from google_containers/kubernetes-dashboard-amd64
9518d8afb433: Pull complete 
Digest: sha256:0ae6b69432e78069c5ce2bcde0fe409c5c4d6f0f4d9cd50a17974fea38898747
Status: Downloaded newer image for registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1
registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1
root@demo:~/k8s# docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1 k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.1
root@demo:~/k8s# docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1
Untagged: registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64:v1.10.1
Untagged: registry.cn-hangzhou.aliyuncs.com/google_containers/kubernetes-dashboard-amd64@sha256:0ae6b69432e78069c5ce2bcde0fe409c5c4d6f0f4d9cd50a17974fea38898747
```

**Step 2:** 服务部署验证测试

``` elixir
root@demo:~/k8s# kubectl create -f kubernetes-dashboard.yaml
secret/kubernetes-dashboard-certs created
serviceaccount/kubernetes-dashboard created
role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
deployment.apps/kubernetes-dashboard created
service/kubernetes-dashboard created
root@demo:~/k8s# kubectl get svc kubernetes-dashboard -n kube-system
NAME                   TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
kubernetes-dashboard   NodePort   10.106.132.216   <none>        443:31081/TCP   34s
root@demo:~/k8s# kubectl get pods -o wide -n kube-system            
NAME                                    READY   STATUS    RESTARTS   AGE   IP                NODE   NOMINATED NODE   READINESS GATES
coredns-6955765f44-qxq5j                1/1     Running   2          61m   10.244.0.9        demo   <none>           <none>
coredns-6955765f44-rt2ns                1/1     Running   2          61m   10.244.0.6        demo   <none>           <none>
etcd-demo                               1/1     Running   1          61m   192.168.114.128   demo   <none>           <none>
kube-apiserver-demo                     1/1     Running   2          61m   192.168.114.128   demo   <none>           <none>
kube-controller-manager-demo            1/1     Running   5          61m   192.168.114.128   demo   <none>           <none>
kube-flannel-ds-amd64-jr4mr             1/1     Running   2          49m   192.168.114.128   demo   <none>           <none>
kube-proxy-sq4ql                        1/1     Running   1          61m   192.168.114.128   demo   <none>           <none>
kube-scheduler-demo                     1/1     Running   5          61m   192.168.114.128   demo   <none>           <none>
kubernetes-dashboard-7c54d59f66-x66k4   1/1     Running   0          39s   10.244.0.10       demo   <none>           <none>
root@demo:~/k8s# ss -lntup |grep 31081
tcp   LISTEN  0        1024                      *:31081                *:*      users:(("kube-proxy",pid=4835,fd=8)) 
```

![图7 Dashboard验证登录](https://github.com/jerome521/go-web-hello-world/blob/master/img/7.png)

#### Task 12: generate token for dashboard login in task 11

**Step1:** 创建服务账号、绑定角色及获取Token

``` elixir
root@demo:~/k8s# more admin-user.yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
root@demo:~/k8s# more admin-user-role-binding.yaml 
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system	
root@demo:~/k8s# kubectl create -f admin-user.yaml
serviceaccount/admin-user created
root@demo:~/k8s# kubectl create -f admin-user-role-binding.yaml
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
root@demo:~/k8s# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
Name:         admin-user-token-zmc7q
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: cab7bd2b-168c-474e-b964-c2d96cc62beb

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6InVKaGdTYkNmR3BCZ3Btand2eEhYYjhaOWh2cm5LWUE2dDZXRWgtWWluSHMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLXptYzdxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJjYWI3YmQyYi0xNjhjLTQ3NGUtYjk2NC1jMmQ5NmNjNjJiZWIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.j6yCk2xqIjI0Wyz731BIkxn-PZAda9rfdt0236b_ncy7n5ydxDiEOd6HoNi8NpgUFd4K1tH9Xh5_yR1Y1EzOQR6EizsSS7jtjxRfaWIzDWkiZ0dEOMzHnMgISO3VMMVCCI77XZH5LapS7WNT0YCPAYM_hnRYlOBr8vPLYXZP_leT7RbLuyA4lneL8d7odZZJD7lCc4y1LhNc47h-Zzur9DFM1JYYWEHb6HXGnazeDS--A3847LthDdr6-JMQpDIO4ZSbrkdshHGR5uJGYvJXKNg3ysjD8hnAdYhRD_om2jWeSkFodLJrr3arehtAJ1H06JjMf1E7-yGCCc-9iF_ayA
```

**Step 2:** 登录验证(火狐浏览器)

 - 使用火狐浏览器访问https://127.0.0.1:31081(虚拟机本地浏览器)，或是访问https://192.168.114.128:31081(宿主机浏览器)进行测试，如下图所示：

![图8 Dashboard管理页面](https://github.com/jerome521/go-web-hello-world/blob/master/img/8.png)

#### Task 13: publish your work

 - 以上为本次测试题详细操作步骤记录，并将所有实验输出物上传至github
 - Github链接：https://github.com/jerome521/go-web-hello-world
