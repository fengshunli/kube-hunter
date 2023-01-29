FROM python:3.11-rc-alpine as builder

RUN apk add --no-cache \
    linux-headers \
    tcpdump \
    build-base \
    ebtables \
    make \
    git && \
    apk upgrade --no-cache

WORKDIR /kube-hunter
COPY setup.py setup.cfg Makefile ./
RUN make deps

COPY . .
RUN make install

FROM python:3.11-rc-alpine

RUN apk add --no-cache \
    tcpdump \
    libuuid \
    ebtables && \
    apk upgrade --no-cache

COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/kube-hunter /usr/local/bin/kube-hunter

# Add default plugins: https://github.com/aquasecurity/kube-hunter-plugins 
RUN pip install kube-hunter-arp-spoof>=0.0.3 kube-hunter-dns-spoof>=0.0.3

ENTRYPOINT ["kube-hunter"]
