FROM bitnami/minideb:stretch as buildenv

RUN install_packages ca-certificates libc6 wget
RUN wget -nc -P /tmp/bitnami/pkg/cache/ https://downloads.bitnami.com/files/stacksmith/oauth2-proxy-0.20180625.74543-3-linux-amd64-debian-9.tar.gz && \
    echo "bec2caf56a9a8f54c0503a45af97c2edd6c6f0fe50f3fed97fa2293d5d8a303c  /tmp/bitnami/pkg/cache/oauth2-proxy-0.20180625.74543-3-linux-amd64-debian-9.tar.gz" | sha256sum -c - && \
    tar -zxf /tmp/bitnami/pkg/cache/oauth2-proxy-0.20180625.74543-3-linux-amd64-debian-9.tar.gz -P --transform 's|^[^/]*/files|/opt/bitnami|' --wildcards '*/files' && \
    rm -rf /tmp/bitnami/pkg/cache/oauth2-proxy-0.20180625.74543-3-linux-amd64-debian-9.tar.gz

##################

FROM bitnami/minideb:stretch
LABEL maintainer "Bitnami <containers@bitnami.com>"

COPY --from=buildenv /opt/bitnami/oauth2-proxy /opt/bitnami/oauth2-proxy
ENV BITNAMI_APP_NAME="oauth2-proxy" \
    BITNAMI_IMAGE_VERSION="0.20180625.74543-debian-9-r40" \
    PATH="/opt/bitnami/oauth2-proxy/bin:$PATH"

ARG di2euser
ARG di2epass
ARG cfsslca
ARG vmhostnames

ENV PKI_TOOLS /pki-tools
ENV PATH /pki-tools:${PATH}
ENV CFSSLCA $cfsslca

RUN install_packages ca-certificates
#RUN apt-get update
RUN install_packages git bison build-essential autopoint libtool automake autoconf gettext pkg-config
RUN git clone https://$di2euser:$di2epass@bitbucket.di2e.net/scm/devcloud/devcloud-pki-mixins.git /pki-tools

RUN mkdir -p /opt/bitnami/oauth2-proxy/tls
RUN cp /pki-tools/ca-bundle.pem /opt/bitnami/oauth2-proxy/tls

#install cfssl cmd line for user convenience
ENV GOPATH /usr/local/go/
ENV PATH $GOPATH/bin:/usr/java/latest/bin:$PATH

WORKDIR /usr/local
RUN install_packages curl
RUN curl -O https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz
RUN tar -xvf go1.9.1.linux-amd64.tar.gz

WORKDIR /usr/local/go/src/github.com/cloudflare/

RUN git clone https://$di2euser:$di2epass@bitbucket.di2e.net/scm/devcloud/cloudflare-cfssl.git cfssl

WORKDIR /usr/local/go/src/

RUN go install github.com/cloudflare/cfssl/cmd/cfssl
RUN go install github.com/cloudflare/cfssl/cmd/cfssl-bundle
RUN go install github.com/cloudflare/cfssl/cmd/cfssl-certinfo
RUN go install github.com/cloudflare/cfssl/cmd/cfssl-newkey
RUN go install github.com/cloudflare/cfssl/cmd/cfssl-scan
RUN go install github.com/cloudflare/cfssl/cmd/cfssljson
RUN go install github.com/cloudflare/cfssl/cmd/mkbundle
RUN go install github.com/cloudflare/cfssl/cmd/multirootca
#RUN bash -c "source pki-tools/env.sh && install-cfssl-debian.sh $di2euser $di2epass"

WORKDIR /opt/bitnami/oauth2-proxy/tls

RUN install_packages jq
RUN gen-save-server-cert-and-key.sh server ${CFSSLCA} ${vmhostnames}
# Append trust chain
RUN cat ${PKI_TOOLS}/ca-bundle.pem >> server.crt 
RUN install_packages vim
RUN cp /pki-tools/ca-bundle.pem /usr/local/share/ca-certificates/ca-bundle.crt
RUN update-ca-certificates

EXPOSE 4180 4181

WORKDIR /opt/bitnami/oauth2-proxy

USER 1001
#CMD ["bash"]
ENTRYPOINT [ "oauth2_proxy" ]
# The cookie secret is Jenny's phone number
CMD [ "--http-address=0.0.0.0:4181", "--https-address=0.0.0.0:4181", "-provider", "oidc", "-client-id", "oauth2_proxy", "--tls-cert=/opt/bitnami/oauth2-proxy/tls/server.crt", "--tls-key=/opt/bitnami/oauth2-proxy/tls/server.pem",\
      "-client-secret", "db8f917f-1980-4e7e-86a1-fb6f230da093", "-redirect-url", "https://dcstgdock02w1a.aws-devcloud.di2e.net:4181/oauth2/callback", "-oidc-issuer-url",\
      "https://dcstgdock02w1a.aws-devcloud.di2e.net:8443/auth/realms/di2e-devcloud", "-cookie-httponly=false", "-cookie-secure=true", "-cookie-secret=8675309", "-email-domain=*"\
      "-scope=\"openid profile role_list\"" ]
