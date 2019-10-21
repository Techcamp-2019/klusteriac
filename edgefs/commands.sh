cd cluster/examples/kubernetes/edgefs
kubectl create -f operator.yaml

# verify the rook-edgefs-operator, and rook-discover pods are in the `Running` state before proceeding
kubectl -n rook-edgefs-system get pod

kubectl create -f cluster.yaml

kubectl -n rook-edgefs get pod



#https://rook.io/docs/rook/v1.1/edgefs-s3-crd.html

kubectl get po --all-namespaces | grep edgefs-mgr

kubectl exec -it -n rook-edgefs rook-edgefs-mgr-5f6d6fd4c8-s776h -- env COLUMNS=$COLUMNS LINES=$LINES TERM=linux toolbox


efscli system status

efscli system init

efscli cluster create Visp

efscli tenant create Visp/Bier
efscli bucket create Visp/Bier/bk1
efscli tenant create Visp/Heida
efscli bucket create Visp/Heida/bk1

efscli service create s3 s3-bier
efscli service serve s3-bier Visp/Bier
efscli service create s3 s3-heida
efscli service serve s3-heida Visp/Heida


efscli service config s3-bier X-Domain bier.com
efscli service config s3-heida X-Domain heida.com



#Test

kubectl create -f toolbox.yaml

kubectl -n rook-ceph get pod -l "app=rook-ceph-tools"

kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') bash



install s3cmd

configure with endpoint: 10.104.73.41:9982

X-Service-Name: s3-bier
X-Service-Type: s3
X-Description: S3 Object
X-Region: -
X-Servers: -
X-Status: disabled
X-Auth-Type: disabled
X-Need-MD5: true
X-ACL-On: false
X-List-Max-Size: 1000
X-List-Cache: true
X-List-All-Buckets: true
X-HTTP-Port: 9982
X-HTTPS-Port: 9443
X-HTTPS-Key: -
X-HTTPS-Cert: -
X-Ciphers: -
X-Default-Tenant: -
X-Default-Owner: -
X-Trust-Proxy: true
X-Access-Log: false
X-Number-Of-Versions: 1
X-Domain: bier.com

root@shell-demo:~# s3cmd ls
2019-10-21 18:33  s3://bk1
2019-10-21 18:33  s3://bk2



X-Service-Name: s3-heida
X-Service-Type: s3
X-Description: S3 Object
X-Region: -
X-Servers: -
X-Status: disabled
X-Auth-Type: disabled
X-Need-MD5: true
X-ACL-On: false
X-List-Max-Size: 1000
X-List-Cache: true
X-List-All-Buckets: true
X-HTTP-Port: 9982
X-HTTPS-Port: 9443
X-HTTPS-Key: -
X-HTTPS-Cert: -
X-Ciphers: -
X-Default-Tenant: -
X-Default-Owner: -
X-Trust-Proxy: true
X-Access-Log: false
X-Number-Of-Versions: 1
X-Domain: heida.com
