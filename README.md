# Lacework Kubernetes Image Scanner
Scan any image running in your Kubernetes cluster, using the Lacework image scanner.

Note:
* This scanner only works with Docker based Kubernetes distributions
* It has only been tested using Minikube

# How to run using Minikube on your Mac desktop
This required Docker Desktop already running.

## Install and start Minikube.
```
$ brew install minikube
$ minikube start
```

## Create credentials for lw-scanner.
See https://support.lacework.com/hc/en-us/articles/1500001777821-Integrate-Inline-Scanner for information on how to configure the lw-scanner.
```
kubectl create secret generic lacework-kubernetes-scanner-credentials \
  --from-literal=access_token=<insert-token-here> \
  --from-literal=account-name=<insert-accunt-name-here>
```

## Deploy Kubernetes scanner
```
$ kubectl apply -f apply -f https://raw.githubusercontent.com/bvboe/lacework-kubernetes-scanner/main/lacework-kubernetes-scanner.yaml
daemonset.apps/lacework-kubernetes-scanner created
```

## Validate the scanner is running
```
$ kubectl logs `kubectl get po | grep Running | grep lacework | awk '{print $1;}' | head -1`
Mon Aug 16 12:33:58 UTC 2021 Scanning running images in the background
Mon Aug 16 12:33:58 UTC 2021 Starting daemon
Mon Aug 16 12:33:58 UTC 2021 Processing image bjornvb/c-test:latest
Mon Aug 16 12:33:58 UTC 2021 Image: bjornvb/c-test
Mon Aug 16 12:33:58 UTC 2021 Tag: latest
Mon Aug 16 12:33:58 UTC 2021 SHA256: sha256:ead152e67ad11c24bd2134eab620cafd8abd3494e61f1570fc6fc588f1afd74f
Mon Aug 16 12:33:58 UTC 2021 Checking scan cache
Mon Aug 16 12:33:58 UTC 2021 Do scan
[WARNING]:   2021-08-16 12:33:58 - LocalScannerClient: Config file not available. Using default config.
 Saving image: Done!
Getting image manifest: Done!
Gathering packages: Done!
Packaging image data: Done!
Evaluating image: Done!
```
## Deploy test application and see new scan triggered
```
$ kubectl create deployment --image nginx:latest test
$ kubectl logs `kubectl get po | grep Running | grep lacework | awk '{print $1;}' | head -1`
Mon Aug 16 12:38:57 UTC 2021 Processing image nginx:latest
Mon Aug 16 12:38:57 UTC 2021 Image: nginx
Mon Aug 16 12:38:57 UTC 2021 Tag: latest
Mon Aug 16 12:38:57 UTC 2021 SHA256: sha256:08b152afcfae220e9709f00767054b824361c742ea03a9fe936271ba520a0a4b
Mon Aug 16 12:38:57 UTC 2021 Checking scan cache
Mon Aug 16 12:38:57 UTC 2021 Do scan
[WARNING]:   2021-08-16 12:38:57 - LocalScannerClient: Config file not available. Using default config.
 Saving image: Done!
Getting image manifest: Done!
Gathering packages: Done!
Packaging image data: Done!
Evaluating image: Done!
                                  CONTAINER IMAGE DETAILS                                          VULNERABILITIES
------------------------------------------------------------------------------------------+---------------------------------
    ID          sha256:08b152afcfae220e9709f00767054b824361c742ea03a9fe936271ba520a0a4b       SEVERITY   COUNT   FIXABLE
    Digest      sha256:8f335768880da6baf72b70c701002b45f4932acae8d574dedfddaf967fc3ac90     -----------+-------+----------
    Registry    remote_scanner                                                                Critical       0         0
    Repository  nginx                                                                         High           2         0
    Size        127.0 MB                                                                      Medium        13         0
    Created At  2021-07-22T10:13:19.618Z                                                      Low           22         0
    Tags        latest                                                                        Info          66         1
```
