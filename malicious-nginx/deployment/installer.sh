---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapplication # name of the deployment
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp # "app: webapp" is the pod selector
  template:
    metadata:
      labels:
        app: webapp # "app: webapp" ensures this pod is part of the deployment itself
    spec:
      containers:
        - image: jmalloc/echo-server # https://hub.docker.com/r/jmalloc/echo-server/
          name: echo
