#!/bin/bash

# exit if script fail
set -e

print_pck_and_dezip() {
	echo $1
	tar -xf $1
}


print_pck_and_dezip man-pages-5.08.tar.xz
pushd man-pages-5.08
	make install
popd

print_pck_and_dezip tcl8.6.10-src.tar.gz
pushd tcl8.6.10-sr
	tar -xf ../tcl8.6.10-html.tar.gz --strip-components=1
	SRCDIR=$(pwd)
	cd unix
	./configure --prefix=/usr --mandir=/usr/share/man $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
	make
	sed -e "s|$SRCDIR/unix|/usr/lib|" -e "s|$SRCDIR|/usr/include|" -i tclConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.1/generic|/usr/include|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.1/library|/usr/lib/tcl8.6|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.1|/usr/include|" \
		-i pkgs/tdbc1.1.1/tdbcConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.0/generic|/usr/include|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.0|/usr/include|" \
		-i pkgs/itcl4.2.0/itclConfig.sh
	unset SRCDIR
	make test
	make install
	chmod -v u+w /usr/lib/libtcl8.6.so
	make install-private-headers
	ln -sfv tclsh8.6 /usr/bin/tclsh
popd

print_pck_and_dezip expect5.45.4.tar.gz
pushd expect5.45.4
	./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --mandir=/usr/share/man --with-tclinclude=/usr/include
	make
	make test
	make install
	ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
popd

print_pck_and_dezip dejagnu-1.6.2.tar.gz

pushd dejagnu-1.6.2
	./configure --prefix=/usr
	makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi
	makeinfo --plaintext -o doc/dejagnu.txt doc/dejagnu.texi
	make install
	install -v -dm755 /usr/share/doc/dejagnu-1.6.2
	install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2
	make check
popd


