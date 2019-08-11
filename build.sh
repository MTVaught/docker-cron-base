#!/bin/bash

docker pull alpine:latest
docker build --tag mtvaught/cron-base:latest .
docker build --tag cron-base-test test/.