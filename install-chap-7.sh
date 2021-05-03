#!/bin/bash

set -e

print_pck_and_dezip() {
	echo $1
	tar -xf $1
}

#rm -rf gcc-10.2.0
#print_pck_and_dezip gcc-10.2.0.tar.xz
#pushd gcc-10.2.0
#	ln -s gthr-posix.h libgcc/gthr-default.h
#	mkdir -v build
#	cd build

#	../libstdc++-v3/configure \
#		CXXFLAGS="-g -O2 -D_GNU_SOURCE" \
#		--prefix=/usr --disable-multilib \
#		--disable-nls --host=$(uname -m)-lfs-linux-gnu \
#		--disable-libstdcxx-pch
#	make
#	make install
#popd

rm -rf gettext-0.21
print_pck_and_dezip gettext-0.21.tar.xz
pushd gettext-0.21
	./configure --disable-shared
	make
	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
popd

rm -rf bison-3.7.1
print_pck_and_dezip bison-3.7.1.tar.xz
pushd bison-3.7.1
	./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.1
	make
	make install
popd

rm -rf perl-5.32.0
print_pck_and_dezip perl-5.32.0.tar.xz
pushd perl-5.32.0
	sh Configure -des -Dprefix=/usr \
		-Dvendorprefix=/usr \
		-Dprivlib=/usr/lib/perl5/5.32/core_perl \
		-Darchlib=/usr/lib/perl5/5.32/core_perl \
		-Dsitelib=/usr/lib/perl5/5.32/site_perl \
		-Dsitearch=/usr/lib/perl5/5.32/site_perl \
		-Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
		-Dvendorarch=/usr/lib/perl5/5.32/vendor_perl
	make
	make install
popd

rm -rf Python-3.8.5
print_pck_and_dezip Python-3.8.5.tar.xz
pushd Python-3.8.5
	./configure --prefix=/usr \
		--enable-shared \
		--without-ensurepip
	make
	make install
popd

rm -rf texinfo-6.7
print_pck_and_dezip texinfo-6.7.tar.xz
pushd texinfo-6.7
	./configure --prefix=/usr
	make
	make install
popd

rm -rf util-linux-2.36
print_pck_and_dezip util-linux-2.36.tar.xz
pushd util-linux-2.36
	mkdir -pv /var/lib/hwclock
	./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
		--docdir=/usr/share/doc/util-linux-2.36 \
		--disable-chfn-chsh \
		--disable-login \
		--disable-nologin \
		--disable-su \
		--disable-setpriv \
		--disable-runuser \
		--disable-pylibmount \
		--disable-static \
		--without-python
	make
	make install
popd

find /usr/{lib,libexec} -name \*.la -delete
rm -rf /usr/share/{info,man,doc}/*
