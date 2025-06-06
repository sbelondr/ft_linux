#!/bin/bash

echo "man-pages-5.13.tar.xz"
tar -xf man-pages-5.13.tar.xz
pushd man-pages-5.13
	make prefix=/usr install
popd
rm -rf man-pages-5.13

echo "iana-etc-20210611.tar.gz"
tar -xf iana-etc-20210611.tar.gz
pushd iana-etc-20210611
	cp services protocols /etc
popd
rm -rf iana-etc-20210611

echo "glibc-2.34.tar.xz"
tar -xf glibc-2.34.tar.xz
pushd glibc-2.34
	sed -e '/NOTIFY_REMOVED)/s/)/ \&\& data.attr != NULL)/' \
		-i sysdeps/unix/sysv/linux/mq_notify.c
	patch -Np1 -i ../glibc-2.34-fhs-1.patch
	mkdir -v build
	pushd build
		echo "rootsbindir=/usr/sbin" > configparms
		../configure --prefix=/usr \
			--disable-werror \
			--enable-kernel=3.2 \
			--enable-stack-protector=strong \
			--with-headers=/usr/include \
			libc_cv_slibdir=/usr/lib
		make
		make check
		touch /etc/ld.so.conf
		sed '/test-installation/s@$(PERL)@echo not running@' \
			-i ../Makefile
		make install
		sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
		cp -v ../nscd/nscd.conf /etc/nscd.conf
		mkdir -pv /var/cache/nscd
		mkdir -pv /usr/lib/locale
		localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
		localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
		localedef -i de_DE -f ISO-8859-1 de_DE
		localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
		localedef -i de_DE -f UTF-8 de_DE.UTF-8
		localedef -i el_GR -f ISO-8859-7 el_GR
		localedef -i en_GB -f ISO-8859-1 en_GB
		localedef -i en_GB -f UTF-8 en_GB.UTF-8
		localedef -i en_HK -f ISO-8859-1 en_HK
		localedef -i en_PH -f ISO-8859-1 en_PH
		localedef -i en_US -f ISO-8859-1 en_US
		localedef -i en_US -f UTF-8 en_US.UTF-8
		localedef -i es_ES -f ISO-8859-15 es_ES@euro
		localedef -i es_MX -f ISO-8859-1 es_MX
		localedef -i fa_IR -f UTF-8 fa_IR
		localedef -i fr_FR -f ISO-8859-1 fr_FR
		localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
		localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
		localedef -i is_IS -f ISO-8859-1 is_IS
		localedef -i is_IS -f UTF-8 is_IS.UTF-8
		localedef -i it_IT -f ISO-8859-1 it_IT
		localedef -i it_IT -f ISO-8859-15 it_IT@euro
		localedef -i it_IT -f UTF-8 it_IT.UTF-8
		localedef -i ja_JP -f EUC-JP ja_JP
		localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS \
			2> /dev/null || true
		localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
		localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
		localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
		localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
		localedef -i se_NO -f UTF-8 se_NO.UTF-8
		localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
		localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
		localedef -i zh_CN -f GB18030 zh_CN.GB18030
		localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
		localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

		make localedata/install-locales
		localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
		localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS \
			2> /dev/null || true
		cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF
		tar -xf ../../tzdata2021a.tar.gz
		ZONEINFO=/usr/share/zoneinfo
		mkdir -pv $ZONEINFO/{posix,right}
		for tz in etcetera southamerica northamerica \
			europe africa antarctica asia australasia \
			backward; do
			zic -L /dev/null -d $ZONEINFO ${tz}
			zic -L /dev/null -d $ZONEINFO/posix ${tz}
			zic -L leapseconds -d $ZONEINFO/right ${tz}
		done
		cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
		zic -d $ZONEINFO -p Europe/Paris
		unset ZONEINFO
		tzselect
		ln -sfv /usr/share/zoneinfo/ /etc/localtime
		cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
		ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
		cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
		cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
		mkdir -pv /etc/ld.so.conf.d
	popd
popd
rm -rf glibc-2.34


echo "zlib-1.2.11.tar.xz"
tar -xf zlib-1.2.11.tar.xz
pushd zlib-1.2.11
	./configure --prefix=/usr
	make
	make check
	make install
	rm -fv /usr/lib/libz.a
popd
rm -rf zlib-1.2.11

echo "bzip2-1.0.8.tar.gz"
tar -xf bzip2-1.0.8.tar.gz
pushd bzip2-1.0.8
	patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	make -f Makefile-libbz2_so
	make clean
	make
	make PREFIX=/usr install
	cp -av libbz2.so.* /usr/lib
	ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
	cp -v bzip2-shared /usr/bin/bzip2
	for i in /usr/bin/{bzcat,bunzip2}; do
		ln -sfv bzip2 $i
	done
	rm -fv /usr/lib/libbz2.a
popd
rm -rf bzip2-1.0.8

echo "xz-5.2.5.tar.xz"
tar -xf xz-5.2.5.tar.xz
pushd xz-5.2.5
	./configure --prefix=/usr \
		--disable-static \
		--docdir=/usr/share/doc/xz-5.2.5
	make
	make check
	make install
popd
rm -rf xz-5.2.5

echo "zstd-1.5.0.tar.gz"
tar -xf zstd-1.5.0.tar.gz
pushd zstd-1.5.0
	make
	make check
	make prefix=/usr install
	rm -v /usr/lib/libzstd.a
popd
rm -rf zstd-1.5.0

echo "file-5.40.tar.gz"
tar -xf file-5.40.tar.gz
pushd file-5.40
	./configure --prefix=/usr
	make
	make check
	make install
popd
rm -rf file-5.40

echo "readline-8.1.tar.gz"
tar -xf readline-8.1.tar.gz
pushd readline-8.1
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr \
		--disable-static \
		--with-curses \
		--docdir=/usr/share/doc/readline-8.1
	make SHLIB_LIBS="-lncursesw"
	make SHLIB_LIBS="-lncursesw" install
	install -v -m644 doc/*.{ps,pdf,html,dvi} \
		/usr/share/doc/readline-8.1
popd
rm -rf readline-8.1

echo "m4-1.4.19.tar.xz"
tar -xf m4-1.4.19
pushd 
	./configure --prefix=/usr
	make
	make check
	make install
popd
rm -rf m4-1.4.19
