#https://rook.io/docs/rook/v1.1/edgefs-s3-crd.html

kubectl get po --all-namespaces | grep edgefs-mgr


kubectl exec -it -n rook-edgefs rook-edgefs-mgr-6cb9597469-czr7p -- env COLUMNS=$COLUMNS LINES=$LINES TERM=linux toolbox


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

