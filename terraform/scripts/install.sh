#! /usr/bin/env bash

apt-get update
apt-get install -f
apt-get install libatomic1 libpython2.7
mkdir /opt/swift
cd /opt/swift
wget --no-check-certificate https://swift.org/builds/swift-4.1.2-release/ubuntu1404/swift-4.1.2-RELEASE/swift-4.1.2-RELEASE-ubuntu14.04.tar.gz
tar -xzf swift-4.1.2-RELEASE-ubuntu14.04.tar.gz
if ! grep -q "swift-4.1.2" ~/.profile; then echo "PATH=\"/opt/swift/swift-4.1.2-RELEASE-ubuntu14.04/usr/bin:$PATH\"" >> ~/.profile; fi;
cd -
