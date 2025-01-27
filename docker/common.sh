#!/usr/bin/env bash

set -x
set -euo pipefail

# shellcheck disable=SC1091
. lib.sh

# For architectures except amd64 and i386, look for packages on ports.ubuntu.com instead.
# This is important if you enable additional architectures so you can install libraries to cross-compile against.
# Look for 'dpkg --add-architecture' in the README for more details.
if grep -i ubuntu /etc/os-release >/dev/null; then
    sed 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch-=amd64,i386] http:\/\/ports.ubuntu.com\/ubuntu-ports\//g' /etc/apt/sources.list > /etc/apt/sources.list.d/ports.list
    sed -i 's/http:\/\/\(.*\).ubuntu.com\/ubuntu\//[arch=amd64,i386] http:\/\/\1.archive.ubuntu.com\/ubuntu\//g' /etc/apt/sources.list
fi

install_packages \
    autoconf \
    automake \
    binutils \
    ca-certificates \
    curl \
    file \
    gcc \
    git \
    libtool \
    m4 \
    make

if_centos install_packages \
    gcc-c++ \
    glibc-devel \
    pkgconfig

if_ubuntu install_packages \
    g++ \
    libc6-dev \
    pkg-config

# Allow for passing in git credentials via environment variable in the format described here https://git-scm.com/docs/git-credential-store#_storage_format
cat <<'EOF' >/usr/local/bin/git_env_credential
#!/bin/bash
echo url=$GIT_CREDENTIALS
EOF

chmod +x /usr/local/bin/git_env_credential
git config --system credential.helper "/usr/local/bin/git_env_credential"
git config --system url."https://".insteadOf ssh://git@
