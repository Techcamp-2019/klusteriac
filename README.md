# Tech Camp Rook on K8

The Goal was to build a Kubernetes Cluster and Deploy EdgeFS with Rook. Achieved so far:

* managed to find a working Github Project to deploy a functional K8 Cluster on Vagrant provisioned nodes.
* managed to deploy Rook on the cluster 
* managed to deploy an EdgeFS Cluster with Rook
* created S3 buckets which could be listed with s3cmd


## Getting a K8 Cluster up and running

Host system with at least 16GB Ram and 4 Cores / 8 Threads

Install required Tools:
* Vagrant v 2.2.6
* Virtualbox v 6.0
* Kubectl

Clone the Repo https://github.com/galexrt/k8s-vagrant-multi-node:
```sh
git clone https://github.com/galexrt/k8s-vagrant-multi-node.git
```

Start the VMs and the cluster with the following command:

```sh
$ NODE_COUNT=3 make up -j4
```

Use 3 Nodes or EdgeFS won't start.

Cluster will be startet fully automated. Check with
```sh
kubectl cluster-info
kubectl get pods -n kube-system
```

##Deploy Rook Operator and Edge FS Cluster

Use the files from https://github.com/rook/rook in /rook/cluster/examples/kubernetes/edgefs/ which are copied into this repo for convenience.
```
kubectl create -f operator.yaml
```
The operator is created in namespace rook-edgefs-system, check with:
```
andri@home-test:~/edgefs/klusteriac/edgefs$ kubectl -n rook-edgefs-system get pods
NAME                                    READY   STATUS    RESTARTS   AGE
rook-discover-5n449                     1/1     Running   1          25h
rook-discover-7g6v4                     1/1     Running   1          25h
rook-discover-z7j6q                     1/1     Running   1          25h
rook-edgefs-operator-66fdc8d49f-tlbgg   1/1     Running   1          25h

```
Once all pods are ready the cluster can be deployed. The examples uses 5GB in /var/lib/edgefs by default. This could be changed to physical disks attached to the K8 nodes.

```
kubectl create -f cluster.yaml
```
```
andri@home-test:~/edgefs/klusteriac/edgefs$ kubectl -n rook-edgefs get pods
NAME                                       READY   STATUS            RESTARTS   AGE
rook-edgefs-mgr-5f6d6fd4c8-s776h           3/3     Running             3          25h
rook-edgefs-target-0                       3/3     Running             3          25h
rook-edgefs-target-1                       3/3     Running             3          25h
rook-edgefs-target-2                       3/3     Running             3          25h
```
Rook starts a Pod for each K8 node plus a manager node. If the pods are not coming up you can check the logs from the Rook operator pod:
```
kubectl -n rook-edgefs get pods
kubectl logs rook-edgefs-operator-<take from previous command> -n rook-edgefs-system
```

## Creating Buckets

According to: #https://rook.io/docs/rook/v1.1/edgefs-s3-crd.html
```sh
#Connect to the manager pod
kubectl get po --all-namespaces | grep edgefs-mgr
kubectl exec -it -n rook-edgefs rook-edgefs-mgr-5f6d6fd4c8-s776h -- env COLUMNS=$COLUMNS LINES=$LINES TERM=linux toolbox

#Check the system 
efscli system status

efscli system init

#Create 2 tenants and a bucket for each
efscli cluster create Visp

efscli tenant create Visp/Bier
efscli bucket create Visp/Bier/flasche
efscli tenant create Visp/Heida
efscli bucket create Visp/Heida/glas

efscli service create s3 s3-bier
efscli service serve s3-bier Visp/Bier
efscli service create s3 s3-heida
efscli service serve s3-heida Visp/Heida

efscli service config s3-bier X-Domain bier.com
efscli service config s3-heida X-Domain heida.com
```
As a test you can list the services available in rook-edgefs

```
andri@home-test:~/edgefs/klusteriac/edgefs$ kubectl get svc -n rook-edgefs
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                       AGE
rook-edgefs-mgr           ClusterIP   10.110.50.178   <none>        6789/TCP                      25h
rook-edgefs-restapi       ClusterIP   10.105.99.217   <none>        8881/TCP,8080/TCP,4443/TCP    25h
rook-edgefs-s3-s3-bier    ClusterIP   10.104.73.41    <none>        49000/TCP,9982/TCP,9443/TCP   113m
rook-edgefs-s3-s3-pepsi   ClusterIP   10.97.102.107   <none>        49000/TCP,9982/TCP,9443/TCP   113m
rook-edgefs-target        ClusterIP   None            <none>        <none>                        25h
rook-edgefs-ui            ClusterIP   10.98.85.10     <none>        3000/TCP,3443/TCP             25h
```

## Test the buckets
This part is not completed it stops at listing the available containers.

Deploy a basic container with a shell in the cluster.

```
kubectl get pod shell-demo

kubectl exec -it shell-demo -- /bin/bash
```

In the container install python and [s3cmd](https://tecadmin.net/install-s3cmd-manage-amazon-s3-buckets/)

```sh
apt-get update
apt-get install wget python3 python3-pip

wget https://sourceforge.net/projects/s3tools/files/s3cmd/2.0.1/s3cmd-2.0.1.tar.gz
tar xzf s3cmd-2.0.1.tar.gz
cd s3cmd-2.0.1

python3 setup.py install

s3cmd --configure

```
See the sample .s3cfg for reference. It is certainly not cofigured properly yet but might be a start.

Now the buckets created in the configured tenant should be visible

```sh
root@shell-demo:~# s3cmd ls
2019-10-21 19:18  s3://bk1
2019-10-21 19:18  s3://bk2
```
However uploading a test file resulted in errors

```
root@shell-demo:~# s3cmd put file.txt s3://bk1
upload: 'file.txt' -> 's3://bk1/file.txt'  [1 of 1]
 37 of 37   100% in    1s    27.59 B/s  done
ERROR: Error parsing xml: not well-formed (invalid token): line 9, column 82
```

## Future Work
Here are some ideas for future tech Camps

* Find a the proper way to expose the EdgeFS Service to the local network or Internet
* Finish the test of S3 buckets and attach a simple application. However, Documentation of EdgeFS is very scarce. Maybe in a few months.
* Try other Services of EdgeFS, NFS, etc.
* Building a geographically distributed cluster would be interesting.
* Use the K8 Cluster builder for other fun projects

