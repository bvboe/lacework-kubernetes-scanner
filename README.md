# Lacework Kubernetes Image Scanner

Scan any image running in your Kubernetes cluster, using the Lacework image scanner.

Note:
* This scanner only works with Docker based Kubernetes distributions
* It has been tested using Minikube and Docker based Kubernetes deployed using Kubeadm

# How to run using Minikube on your Mac desktop
This required Docker Desktop already running.

## Install and start Minikube.
```
$ brew install minikube
$ minikube start
```

## Create credentials for lw-scanner and lacework cli
See https://support.lacework.com/hc/en-us/articles/1500001777821-Integrate-Inline-Scanner and https://support.lacework.com/hc/en-us/articles/1500001558282-Install-and-Configure-the-Lacework-CLI for more information.
```
kubectl create secret generic lacework-kubernetes-scanner-credentials \
  --from-literal=lw_scanner_access_token=<insert-lw-scanner-token-here> \
  --from-literal=lw_account_name=<insert-lw-accunt-name-here> \
  --from-literal=lw_api_key=<insert-lw-api-key> \
  --from-literal=lw_api_secret=<insert-lw-api-secret>
```

## Deploy Kubernetes scanner
```
$ kubectl apply -f https://raw.githubusercontent.com/bvboe/lacework-kubernetes-scanner/main/lacework-kubernetes-scanner.yaml
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
## Delete scanner
```
$ kubectl delete -f https://raw.githubusercontent.com/bvboe/lacework-kubernetes-scanner/main/lacework-kubernetes-scanner.yaml
```
## Shut down Minikube
```
$ minikube delete
```
# Run images scanner locally on your desktop
## Pre-requisites
* Install Docker desktop
* Lacework lw-scanner downloaded from https://github.com/lacework/lacework-vulnerability-scanner/releases and in the execution path
* Git client
## Clear Docker image cache
```
$ docker images prune -a
```
## Download scanner
```
$ git clone https://github.com/bvboe/lacework-kubernetes-scanner
Cloning into 'lacework-kubernetes-scanner'...
remote: Enumerating objects: 24, done.
remote: Counting objects: 100% (24/24), done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 24 (delta 6), reused 17 (delta 3), pack-reused 0
Receiving objects: 100% (24/24), 4.90 KiB | 2.45 MiB/s, done.
Resolving deltas: 100% (6/6), done.

$ cd lacework-kubernetes-scanner/src
```
## Configure scanner and lacework cli
See https://support.lacework.com/hc/en-us/articles/1500001777821-Integrate-Inline-Scanner and https://support.lacework.com/hc/en-us/articles/1500001558282-Install-and-Configure-the-Lacework-CLI for more information.
```
$ export LW_SCANNER_ACCESS_TOKEN=<insert-lw-scanner-token-here>
$ export LW_ACCOUNT_NAME=<insert-lw-accunt-name-here>
$ export LW_API_KEY=<insert-lw-api-key>
$ export LW_API_SECRET=<insert-lw-api-secret>
```
## Start scanner
```
$ ./scanner-daemon.sh
Mon Aug 16 09:09:20 EDT 2021 Scanning running images in the background
Mon Aug 16 09:09:20 EDT 2021 Starting daemon
```
## Test scanner
In a separate window, run the following command to download an image:
```
$ docker pull nginx:latest
latest: Pulling from library/nginx
```
Observe the scan automatically running in the other window.

## Scan cache
Note that the scanner keeps a cache of already scanned images in `/tmp/scan-cache.txt`, which can be cleared by deleting the file. It's also querying the lacework API to ensure each image is only scanned once.
