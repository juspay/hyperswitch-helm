# Hyperswitch Helm Chart
This `hyperswitch-helm` Helm chart is a community maintained chart.

## Prerequisites

Make sure you have Helm [installed](https://helm.sh/docs/using_helm/#installing-helm).

## Get Repo Info

```console
helm repo add hyperswitch-helm https://juspay.github.io/hyperswitch-helm
helm repo update
```

## Contribution guidelines
When you want others to use the changes you have added you need to package it and then index it

```helm package .
helm repo index . --url https://juspay.github.io/hyperswitch-helm```
