#!/bin/bash

echo "****SET HOSTNAME****"
read -p "Masukkan Hostname misalkan KF-postgresql : " hostname
hostnamectl set-hostname $hostname
echo "****Install node_exporter****"
version="${VERSION:-1.1.1}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/local/bin}"

wget "https://github.com/prometheus/node_exporter/releases/download/v$version/node_exporter-$version.$arch.tar.gz" \
    -O /tmp/node_exporter.tar.gz

mkdir -p /tmp/node_exporter

cd /tmp || { echo "ERROR! No /tmp found.."; exit 1; }

tar xfz /tmp/node_exporter.tar.gz -C /tmp/node_exporter || { echo "ERROR! Extracting the node_exporter tar"; exit 1; }

cp "/tmp/node_exporter/node_exporter-$version.$arch/node_exporter" "$bin_dir"

useradd -rs /bin/false node_exporter

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter
systemctl status node_exporter
echo "SUCCESS! Installation succeeded!"
curl localhost:9100/metrics
cat /etc/hostname
