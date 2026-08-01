#!/bin/sh
# Apply project-specific patches to feed packages.
# Run this after './scripts/feeds update -a' and before building.
set -e

cd "$(dirname "$0")/.."

install -Dm644 feeds-patches/perl/1000-sdbm-gcc15.patch \
	feeds/packages/lang/perl/patches/1000-sdbm-gcc15.patch
install -Dm644 feeds-patches/samba4/990-memset-explicit-gcc15.patch \
	feeds/packages/net/samba4/patches/990-memset-explicit-gcc15.patch

echo "Feed patches applied."
