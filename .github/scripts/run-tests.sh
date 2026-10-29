#!/bin/sh
set -eu

src="$(pwd)"

apk add --no-cache curl perl bash wget git perl-dev libarchive-tools jq
ln -sf /usr/bin/bsdtar /usr/bin/tar

case "$OPENRESTY_VERSION" in
  1.17.8.2)
    mkdir -p /tmp/expat
    curl -Ls "$LIBEXPAT_DOWNLOAD_URL" | tar -xz --strip-components=1 -f - -C /tmp/expat
    (cd /tmp/expat && ./configure && make && make install)
    ;;
  1.19.9.1)
    apk add --no-cache expat-dev
    ;;
esac

cd /tmp
wget https://luarocks.github.io/luarocks/releases/luarocks-3.12.2.tar.gz
tar zxvf luarocks-3.12.2.tar.gz
cd luarocks-3.12.2
./configure \
  --lua-version=5.1 \
  --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
  --with-lua-lib=/usr/local/openresty/luajit/lib
make
make install

export PATH=/usr/local/bin:$PATH
luarocks install busted
luarocks install luatz
luarocks install luasocket

cd "$src"
luarocks make
busted
