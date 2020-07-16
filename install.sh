#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")
SECRET_NAME=$(kubectl get secrets | grep ^default | cut -f1 -d ' ')
TOKEN=$(kubectl describe secret $SECRET_NAME | grep -E '^token' | cut -f2 -d':' | tr -d " ")


install_kubemon() {
    
    # Add proper values to files
    sed -i -e "s#api-server#${APISERVER}#" kubemon-deployment.yaml
    sed -i -e "s/access-token/${TOKEN}/" kubemon-deployment.yaml
    printf "${GREEN}Creating kubemon namepace...\n"
    kubectl create clusterrolebinding cluster-system-anonymous --clusterrole=cluster-admin --user=system:anonymous
    kubectl apply -f kubemon-namespace.yaml
    kubectl apply -f kubemon-service.yaml
    kubectl apply -f kubemon-deployment.yaml
    POD=$(kubectl get po -n kubemon | awk '{print $1}'| tail -1)
    printf "\n"
    printf "Wait for deployment to get ready"
    kubectl get po -n kubemon 
}

remove_kubemon() {
    
    kubectl delete -f kubemon-deployment.yaml
    kubectl delete -f kubemon-service.yaml
    kubectl delete -f kubemon-namepace.yaml

}

menu() {
clear
printf "${GREEN}1.Install kubemon\n2.Remove kubemon\n${NC}"
read CHOICE

case $CHOICE in

  1)
    install_kubemon
    ;;

  2)
    remove_kubemon
    ;;
  *)
    exit
    ;;
esac
}
menu
printf "${NC}"