#!/bin/bash

array=(a b c d e f g h i j k l m n o p q r s -beta5)
typeset -i i=0 max=${#array[*]}
docker build --build-arg VERSION= -t openssl-1_0_0-server -f Dockerfile-1_0_0x .
while (( i < max ))
do
	echo "Feld $i: Openssl 1.0.0${array[$i]}"
	docker build --build-arg VERSION=${array[$i]} -t openssl-1_0_0${array[$i]}-server -f Dockerfile-1_0_0x .
	i=i+1
done
docker build --build-arg VERSION=-beta1 -t openssl-1_0_0-beta1-server -f Dockerfile-1_0_0beta1-4 .
docker build --build-arg VERSION=-beta2 -t openssl-1_0_0-beta2-server -f Dockerfile-1_0_0beta1-4 .
docker build --build-arg VERSION=-beta3 -t openssl-1_0_0-beta3-server -f Dockerfile-1_0_0beta1-4 .
docker build --build-arg VERSION=-beta4 -t openssl-1_0_0-beta4-server -f Dockerfile-1_0_0beta1-4 .