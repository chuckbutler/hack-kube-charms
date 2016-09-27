#!/usr/bin/env bash 
 
set -ex



# Quick function to enable forking of repositories
fork_repo(){
 # inline call, bail if doing nothing
 if [ "${SETUPFORKING}" == "n" ]; then
return
 fi
 cd $1
 hub fork
 cd ..
}


# Gather pre-dependencies 
if [ -z ${LAYER_PATH} ] 
then 
 echo "Missing LAYER_PATH environment variable. Cowardly exiting." 
 exit 1 
fi 
 
if [ -z ${INTERFACE_PATH} ] 
then 
 echo "Missing INTERFACE_PATH environment variable. Cowardly exiting." 
 exit 1 
fi 


# helping a noob out
mkdir -p $LAYER_PATH
mkdir -p $INTERFACE_PATH
 

set +e 
HUB_BIN=$(which hub) 
set -e
 
if [ -z ${HUB_BIN} ] 
then 
 echo "It appears you dont have the github-hub application. Would you like to install it now? [y/n]"
 read USER_INPUT 
 
 if [ "${USER_INPUT}" != "n" ]; then
 echo "Grabbing hub binary" 
 wget -nc https://github.com/github/hub/releases/download/v2.2.8/hub-linux-amd64-2.2.8.tgz -O hub.tar.gz
 tar xvfz hub.tar.gz -C /tmp/
 /tmp/hub*/install 
 fi 
fi 



# Convenience method to ensure we can immediately contribute to the layers on clone
echo "Would you like to fork the layers and interfaces cloned? [y/n]"
read SETUPFORKING 


echo "Cloning repositories..."

SOLUTIONS=https://github.com/juju-solutions/

set +e

echo "Clone project layers now? [y/n]"
read USER_INPUT 

if [ "${USER_INPUT}" != "n" ]; then
cd $LAYER_PATH
echo " "
echo "======================== "
echo "Cloning layers..."
echo "======================== "


hub clone $SOLUTIONS/layer-docker docker
 fork_repo 'docker'
hub clone $SOLUTIONS/layer-etcd etcd
 fork_repo 'etcd'
hub clone $SOLUTIONS/layer-easyrsa easyrsa
 fork_repo 'easyrsa'
hub clone $SOLUTIONS/layer-flannel flannel
fork_repo 'flannel'
echo "This is a big one...."
hub clone $SOLUTIONS/kubernetes kubernetes
echo " "
 echo " "
echo "Done... layers are in kubernetes/cluster/juju/layers/"
 echo " "
 echo " "
hub clone $SOLUTIONS/layer-tls-client tls-client
fork_repo 'tls-client'
fi 




echo "Clone project interfaces now? [y/n]"
read USER_INPUT 

if [ "${USER_INPUT}" != "n" ]; then
echo " "
echo " "
echo " "
echo " "

echo " "
echo "======================== "
echo "Cloning interfaces..."
echo "======================== "

cd $INTERFACE_PATH
hub clone $SOLUTIONS/interface-etcd etcd
fork_repo 'etcd'
hub clone $SOLUTIONS/interface-etcd-proxy etcd-proxy
fork_repo 'etcd-proxy'
hub clone $SOLUTIONS/interface-http http
fork_repo 'http'
hub clone $SOLUTIONS/interface-kube-api kube-api
fork_repo 'kube-api'
hub clone $SOLUTIONS/interface-juju-info juju-info
fork_repo 'juju-info'
hub clone $SOLUTIONS/interface-kube-dns kube-dns
fork_repo 'kube-dns'
hub clone $SOLUTIONS/interface-sdn-plugin sdn-plugin
fork_repo 'sdn-plugin'
hub clone $SOLUTIONS/interface-tls tls
fork_repo 'tls'
hub clone $SOLUTIONS/interface-tls-certificates tls-certificates
fork_repo 'tls-certificates'
hub clone $SOLUTIONS/interface-public-address public-address
fi


echo "Clone layers for beats stack now? [y/n]"
read USER_INPUT 

if [ "${USER_INPUT}" != "n" ]; then
cd $LAYER_PATH
hub clone $SOLUTIONS/layer-beats-base beats-base
fork_repo 'beats-base'
hub clone $SOLUTIONS/layer-filebeat filebeat
fork_repo 'filebeat'
hub clone $SOLUTIONS/layer-topbeat topbeat
fork_repo 'topbeat'
hub clone $SOLUTIONS/layer-packetbeat packetbeat
fork_repo 'packetbeat'
 # not a typo
hub clone $SOLUTIONS/layer-dockerbeat dockbeat
fork_repo 'dockbeat'
 cd $INTERFACE_PATH
hub clone $SOLUTIONS/interface-beats-host beats-host
fork_repo 'beats-host'
 hub clone $SOLUTIONS/interface-elastic-beats elastic-beats
fork_repo 'elastic-beats'
 hub clone $SOLUTIONS/interface-elasticsearch elasticsearch
fork_repo 'elasticsearch'
 hub clone $SOLUTIONS/interface-logstash logstash
fork_repo 'logstash'
fi

echo ""
echo ""
echo ""
echo ""
echo "Every upstream is now set to origin. Simply push to your fork. use hub to automate pull rquests"
echo " "
echo "hub pull-request -h myname:branch -b origin:master"
echo " "
echo "Fin!"