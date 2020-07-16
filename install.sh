#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
SECRET_NAME=$(kubectl get secrets | grep ^default | cut -f1 -d ' ')
TOKEN=$(kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")

sed -i -e "s#api-server#${APISERVER}#" kubemon-deployment.yaml
sed -i -e "s/access-token/${TOKEN}/" kubemon-deployment.yaml

install_kubemon() {
    printf "${GREEN}Creating kubemon namepace...\n"
    kubectl apply -f kubemon-namespace.yaml
    kubectl apply -f kubemon-service.yaml
    kubectl apply -f kubemon-deployment.yaml
    POD=$(kubectl get po -n kubemon | awk '{print $1}'| tail -1)
    printf "\n"
    printf "Waiting for deployment to get ready"
    kubectl wait --for=condition=Ready -n kubemon pod/$POD
}
