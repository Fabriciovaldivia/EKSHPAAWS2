#!/usr/bin/env bash

kubectl exec -it nginx-deployment-7684ccb85-gr74n -- sh

while true; do wget -q -O- http://nginx-lb; done
