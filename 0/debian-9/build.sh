#!/bin/sh
docker build --build-arg cfsslca=dcstgdock08w1a.aws-devcloud.di2e.net --build-arg di2euser="username" --build-arg di2epass="password" --build-arg vmhostnames="dcstgdock02w1a.aws-devcloud.di2e.net" -t bitnami/oauth2-proxy:latest .
