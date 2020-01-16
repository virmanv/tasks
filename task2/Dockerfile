FROM alpine:3.10 as builder

LABEL maintainer=vidhivirmani@yahoo.com

ARG Version=unset

RUN apk update && apk add git && apk add ca-certificates && apk add tzdata && apk add curl

#download kubectl and helm and aws-cli
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
RUN curl -LO https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz
RUN tar -zxvf helm-v2.14.3-linux-amd64.tar.gz
RUN apk -Uuv add groff less python py-pip
RUN pip install awscli
RUN apk --purge -v del py-pip
RUN rm /var/cache/apk/*
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
RUN aws eks update-kubeconfig --name tf-eks-cluster  --region=ap-southeast-2

WORKDIR /task2
COPY . /task2

RUN kubectl apply -f deployment.yaml
RUN kubectl apply -f service.yaml
RUN kubectl apply -f vs.yaml
RUN kubectl apply -f gw.yaml






