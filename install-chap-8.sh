#!/bin/bash

# exit if script fail
set -e

print_pck_and_dezip() {
	echo $1
	tar -xf $1
}

read_input() {
	echo "$1"
	read -p "Press enter to continue..."
}

chmod 666 /dev/ptmx
chmod 666 /dev/null

rm -rf man-pages-5.10
print_pck_and_dezip man-pages-5.10.tar.xz
pushd man-pages-5.10
	make install
popd


rm -rf iana-etc-20210202
print_pck_and_dezip iana-etc-20210202.tar.gz

pushd iana-etc-20210202
	cp services protocols /etc
popd

rm -rf glibc-2.33
print_pck_and_dezip glibc-2.33.tar.xz

pushd glibc-2.33
	patch -Np1 -i ../glibc-2.33-fhs-1.patch
	sed -e '402a\	*result = local->data.services[database_index];' \
		-i nss/nss_database.c

	mkdir -v build
	cd build
	../configure --prefix=/usr                   \
		--disable-werror                         \
		--enable-kernel=3.2                      \
		--enable-stack-protector=strong          \
		--with-headers=/usr/include              \
		libc_cv_slibdir=/lib
	make
	make check || read_input "glibc"
	touch /etc/ld.so.conf
	sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
	make install
	cp -v ../nscd/nscd.conf /etc/nscd.conf
	mkdir -pv /var/cache/nscd
	mkdir -pv /usr/lib/locale
	localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
	localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
	localedef -i de_DE -f ISO-8859-1 de_DE
	localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
	localedef -i de_DE -f UTF-8 de_DE.UTF-8
	localedef -i el_GR -f ISO-8859-7 el_GR
	localedef -i en_GB -f UTF-8 en_GB.UTF-8
	localedef -i en_HK -f ISO-8859-1 en_HK
	localedef -i en_PH -f ISO-8859-1 en_PH
	localedef -i en_US -f ISO-8859-1 en_US
	localedef -i en_US -f UTF-8 en_US.UTF-8
	localedef -i es_MX -f ISO-8859-1 es_MX
	localedef -i fa_IR -f UTF-8 fa_IR
	localedef -i fr_FR -f ISO-8859-1 fr_FR
	localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
	localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
	localedef -i it_IT -f ISO-8859-1 it_IT
	localedef -i it_IT -f UTF-8 it_IT.UTF-8
	localedef -i ja_JP -f EUC-JP ja_JP
	localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
	localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
	localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
	localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
	localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
	localedef -i zh_CN -f GB18030 zh_CN.GB18030
	localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS

	make localedata/install-locales
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
	for tz in etcetera southamerica northamerica europe africa antarctica  \
	asia australasia backward pacificnew systemv; do
		zic -L /dev/null   -d $ZONEINFO       ${tz}
		zic -L /dev/null   -d $ZONEINFO/posix ${tz}
		zic -L leapseconds -d $ZONEINFO/right ${tz}
	done
	cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
	zic -d $ZONEINFO -p America/New_York
	unset ZONEINFO

	tzselect
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


rm -rf zlib-1.2.11
print_pck_and_dezip zlib-1.2.11.tar.xz

pushd zlib-1.2.11
	./configure --prefix=/usr
	make
	make check || read_input "zlib"
	make install
	mv -v /usr/lib/libz.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
	rm -fv /usr/lib/libz.a
popd


rm -rf bzip2-1.0.8
print_pck_and_dezip bzip2-1.0.8.tar.gz

pushd bzip2-1.0.8
	patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
	sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
	sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
	make -f Makefile-libbz2_so
	make clean
	make
	make PREFIX=/usr install
	cp -v bzip2-shared /bin/bzip2
	cp -av libbz2.so* /lib
	ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
	rm -v /usr/bin/{bunzip2,bzcat,bzip2}
	ln -sv bzip2 /bin/bunzip2
	ln -sv bzip2 /bin/bzcat
	rm -fv /usr/lib/libbz2.a
popd


rm -rf xz-5.2.5
print_pck_and_dezip xz-5.2.5.tar.xz

pushd xz-5.2.5
	./configure --prefix=/usr    \
		--disable-static		 \
		--docdir=/usr/share/doc/xz-5.2.5
	make
	make check || read_input "xz"
	make install
	mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
	mv -v /usr/lib/liblzma.so.* /lib
	ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
popd


rm -rf zstd-1.4.8
print_pck_and_dezip zstd-1.4.8.tar.gz

pushd zstd-1.4.8
	make
	make check || read_input "zstd"
	make prefix=/usr install
	rm -v /usr/lib/libzstd.a
	mv -v /usr/lib/libzstd.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so
popd

rm -rf file-5.39
print_pck_and_dezip file-5.39.tar.gz

pushd file-5.39
	./configure --prefix=/usr
	make
	make check || read_input "file"
	make install
popd


rm -rf readline-8.1
print_pck_and_dezip readline-8.1.tar.gz

pushd readline-8.1
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr    \
		--disable-static \
		--with-curses    \
		--docdir=/usr/share/doc/readline-8.1
	make SHLIB_LIBS="-lncursesw"
	make SHLIB_LIBS="-lncursesw" install
	mv -v /usr/lib/lib{readline,history}.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
	ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1
popd

rm -rf m4-1.4.18
print_pck_and_dezip m4-1.4.18.tar.xz

pushd m4-1.4.18
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
	./configure --prefix=/usr
	make
	make check || read_input "m4"
	make install
popd


rm -rf bc-3.3.0
print_pck_and_dezip bc-3.3.0.tar.xz

pushd bc-3.3.0
	PREFIX=/usr CC=gcc CFLAGS="-std=c99" ./configure.sh -G -O3
	make
	make test || read_input "bc"
	make install
popd


rm -rf flex-2.6.4
print_pck_and_dezip flex-2.6.4.tar.gz

pushd flex-2.6.4
	./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
	make
	make check || read_input "flex"
	make install
	ln -sv flex /usr/bin/lex
popd

rm -rf tcl8.6.11
print_pck_and_dezip tcl8.6.11-src.tar.gz
pushd tcl8.6.11
	tar -xf ../tcl8.6.11-html.tar.gz --strip-components=1
	SRCDIR=$(pwd)
	cd unix
	./configure --prefix=/usr --mandir=/usr/share/man $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
	make
	sed -e "s|$SRCDIR/unix|/usr/lib|" -e "s|$SRCDIR|/usr/include|" -i tclConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
		-e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|" \
		-i pkgs/tdbc1.1.2/tdbcConfig.sh
	sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|" \
		-e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|" \
		-i pkgs/itcl4.2.1/itclConfig.sh
	unset SRCDIR
	make test || read_input "tcl"
	make install
	chmod -v u+w /usr/lib/libtcl8.6.so
	make install-private-headers
	ln -sfv tclsh8.6 /usr/bin/tclsh
	mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
popd

rm -rf expect5.45.4
print_pck_and_dezip expect5.45.4.tar.gz
pushd expect5.45.4
	./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --mandir=/usr/share/man --with-tclinclude=/usr/include
	make
	make test || read_input "expect"
	make install
	ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
popd

rm -rf dejagnu-1.6.2
print_pck_and_dezip dejagnu-1.6.2.tar.gz

pushd dejagnu-1.6.2
	./configure --prefix=/usr
	makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi
	makeinfo --plaintext -o doc/dejagnu.txt doc/dejagnu.texi
	make install
	install -v -dm755 /usr/share/doc/dejagnu-1.6.2
	install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2
	make check || read_input "dejagnu"
popd

rm -rf binutils-2.36.1
print_pck_and_dezip binutils-2.36.1.tar.xz

pushd binutils-2.36.1
	expect -c "spawn ls"
	read_input "binutils"
	sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
	mkdir -v build
	cd build
	../configure --prefix=/usr       \
		--enable-gold       \
		--enable-ld=default \
		--enable-plugins    \
		--enable-shared     \
		--disable-werror    \
		--enable-64-bit-bfd \
		--with-system-zlib
	make tooldir=/usr
	make -k check || read_input "binutils"
	make tooldir=/usr install
	rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
popd

rm -rf gmp-6.2.1
print_pck_and_dezip gmp-6.2.1.tar.xz

pushd gmp-6.2.1
	./configure --prefix=/usr    \
		--enable-cxx     \
        --disable-static \
        --docdir=/usr/share/doc/gmp-6.2.1
	make
	make html
	make check 2>&1 | tee gmp-check-log
	awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
	make install
	make install-html
popd


rm -rf mpfr-4.1.0
print_pck_and_dezip mpfr-4.1.0.tar.xz

pushd mpfr-4.1.0
	./configure --prefix=/usr \
		--disable-static \
        --enable-thread-safe \
        --docdir=/usr/share/doc/mpfr-4.1.0
	make
	make html
	make check || read_input "mpfr"
	make install
	make install-html
popd

rm -rf mpc-1.2.1
print_pck_and_dezip mpc-1.2.1.tar.gz

pushd mpc-1.2.1
	./configure --prefix=/usr \
		--disable-static \
		--docdir=/usr/share/doc/mpc-1.2.1
	make
	make html
	make check || read_input "mpc"
	make install
	make install-html
popd


rm -rf attr-2.4.48
print_pck_and_dezip attr-2.4.48.tar.gz

pushd attr-2.4.48
	./configure --prefix=/usr     \
		--disable-static  \
        --sysconfdir=/etc \
        --docdir=/usr/share/doc/attr-2.4.48
	make
	make check || read_input "attr"
	make install
	mv -v /usr/lib/libattr.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
popd

rm -rf acl-2.2.53
print_pck_and_dezip acl-2.2.53.tar.gz

pushd acl-2.2.53
	./configure --prefix=/usr         \
		--bindir=/bin \
		--disable-static      \
		--libexecdir=/usr/lib \
		--docdir=/usr/share/doc/acl-2.2.53
	make
	make install
	mv -v /usr/lib/libacl.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
popd

rm -rf libcap-2.48
print_pck_and_dezip libcap-2.48.tar.xz

pushd libcap-2.48
	sed -i '/install -m.*STACAPLIBNAME/d' libcap/Makefile
	make prefix=/usr lib=lib
	make test || read_input "libcap"
	make prefix=/usr lib=lib install
	for libname in cap psx; do
		mv -v /usr/lib/lib${libname}.so.* /lib
		ln -sfv ../../lib/lib${libname}.so.2 \
			/usr/lib/lib${libname}.so
		chmod -v 755 /lib/lib${libname}.so.2.48
	done
popd



rm -rf shadow-4.8.1
print_pck_and_dezip shadow-4.8.1.tar.xz

pushd shadow-4.8.1
	sed -i 's/groups$(EXEEXT) //' src/Makefile.in
	find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
	find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
	find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
	sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
		-e 's:/var/spool/mail:/var/mail:'                 \
		-i etc/login.defs
	sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs
	sed -i 's/1000/999/' etc/useradd
	touch /usr/bin/passwd
	./configure --sysconfdir=/etc \
		--with-group-name-max-length=32
	make
	make install
	pwconv
	grpconv
	sed -i 's/yes/no/' /etc/default/useradd
	passwd root
popd


rm -rf gcc-10.2.0
print_pck_and_dezip gcc-10.2.0.tar.xz

pushd gcc-10.2.0
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' \
				-i.orig gcc/config/i386/t-linux64
		;;
	esac
	mkdir -v build
	cd build
	../configure --prefix=/usr \
		LD=ld \
		--enable-languages=c,c++ \
		--disable-multilib \
		--disable-bootstrap \
		--with-system-zlib
	make
	ulimit -s 32768
	chown -Rv tester .
	su tester -c "PATH=$PATH make -k check"
	../contrib/test_summary
	make install
	rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/10.2.0/include-fixed/bits/
	chown -v -R root:root \
		/usr/lib/gcc/*linux-gnu/10.2.0/include{,-fixed}
	ln -svf ../usr/bin/cpp /lib
	# install -v -dm755 /usr/lib/bfd-plugins
	ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/10.2.0/liblto_plugin.so \
		/usr/lib/bfd-plugins/
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	readelf -l a.out | grep ': /lib'
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
	grep -B4 '^ /usr/include' dummy.log
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
	grep "/lib.*/libc.so.6 " dummy.log
	grep found dummy.log
  read_input "gcc"
	rm -v dummy.c a.out dummy.log
	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	# read_input "check gcc"
popd

rm -rf pkg-config-0.29.2
print_pck_and_dezip pkg-config-0.29.2.tar.gz

pushd pkg-config-0.29.2
	./configure --prefix=/usr    \
		--with-internal-glib       \
		--disable-host-tool        \
		--docdir=/usr/share/doc/pkg-config-0.29.2
	make
	make check || read_input "pkg-config"
	make install
popd

rm -rf ncurses-6.2
print_pck_and_dezip ncurses-6.2.tar.gz

pushd ncurses-6.2
	# sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
	./configure --prefix=/usr \
		--mandir=/usr/share/man \
		--with-shared           \
		--without-debug         \
		--without-normal        \
		--enable-pc-files       \
		--enable-widec
	make
	make install
	mv -v /usr/lib/libncursesw.so.6* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
	for lib in ncurses form panel menu ; do
		rm -vf /usr/lib/lib${lib}.so
		echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
		ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
	done
	rm -vf /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	ln -sfv libncurses.so      /usr/lib/libcurses.so
  rm -fv /usr/lib/libncurses++w.a
	mkdir -v /usr/share/doc/ncurses-6.2
	cp -v -R doc/* /usr/share/doc/ncurses-6.2

	# bonus
	make distclean
	./configure --prefix=/usr    \
		--with-shared    \
		--without-normal \
		--without-debug  \
		--without-cxx-binding \
		--with-abi-version=5
	make sources libs
	cp -av lib/lib*.so.5* /usr/lib
popd

rm -rf sed-4.8
print_pck_and_dezip sed-4.8.tar.xz

pushd sed-4.8
	./configure --prefix=/usr --bindir=/bin
	make
	make html
	chown -Rv tester .
	su tester -c "PATH=$PATH make check"
	make install
	install -d -m755           /usr/share/doc/sed-4.8
	install -m644 doc/sed.html /usr/share/doc/sed-4.8
popd


rm -rf psmisc-23.4
print_pck_and_dezip psmisc-23.4.tar.xz

pushd psmisc-23.4
	./configure --prefix=/usr
	make
	make install
	mv -v /usr/bin/fuser /bin
	mv -v /usr/bin/killall /bin
popd

rm -rf gettext-0.21
print_pck_and_dezip gettext-0.21.tar.xz

pushd gettext-0.21
	./configure --prefix=/usr    \
		--disable-static \
    --docdir=/usr/share/doc/gettext-0.21
	make
	make check || read_input "gettext"
	make install
	chmod -v 0755 /usr/lib/preloadable_libintl.so
popd

rm -rf bison-3.7.5
print_pck_and_dezip bison-3.7.5.tar.xz

pushd bison-3.7.5
	./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.5
	make
	make check || read_input "bison"
	make install
popd

rm -rf grep-3.6
print_pck_and_dezip grep-3.6.tar.xz

pushd grep-3.6
	./configure --prefix=/usr --bindir=/bin
	make
	make check || read_input "grep"
	make install
popd


rm -rf bash-5.1
print_pck_and_dezip bash-5.1.tar.gz

pushd bash-5.1
	sed -i  '/^bashline.o:.*shmbchar.h/a bashline.o: ${DEFDIR}/builtext.h' \
		Makefile.in
	# patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch
	./configure --prefix=/usr \
		--docdir=/usr/share/doc/bash-5.1 \
		--without-bash-malloc \
		--with-installed-readline
	make
	chown -Rv tester .
	su tester << EOF
PATH=$PATH make tests < $(tty)
EOF
	make install
	mv -vf /usr/bin/bash /bin
	# exec /bin/bash --login +h
	read_input "launch 'exec /bin/bash --login +h'"
popd

rm -rf libtool-2.4.6
print_pck_and_dezip libtool-2.4.6.tar.xz

pushd libtool-2.4.6
	./configure --prefix=/usr
	make
	make check || read_input "libtool"
	make install
	rm -fv /usr/lib/libltdl.a
popd

rm -rf gdbm-1.19
print_pck_and_dezip gdbm-1.19.tar.gz

pushd gdbm-1.19
	./configure --prefix=/usr \
		--disable-static \
		--enable-libgdbm-compat
	make
	make check || read_input "gdbm"
	make install
popd

rm -rf gperf-3.1
print_pck_and_dezip gperf-3.1.tar.gz

pushd gperf-3.1
	./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
	make
	make -j1 check
	make install
popd


rm -rf expat-2.2.10
print_pck_and_dezip expat-2.2.10.tar.xz

pushd expat-2.2.10
	./configure --prefix=/usr \
		--disable-static \
		--docdir=/usr/share/doc/expat-2.2.10
	make
	make check || read_input "expat"
	make install
	install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.10
popd

rm -rf inetutils-2.0
print_pck_and_dezip inetutils-2.0.tar.xz

pushd inetutils-2.0
	./configure --prefix=/usr \
		--localstatedir=/var \
		--disable-logger \
		--disable-whois \
		--disable-rcp \
		--disable-rexec \
		--disable-rlogin \
		--disable-rsh \
		--disable-servers
	make
	make check || read_input "inetutils"
	make install
	mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
	mv -v /usr/bin/ifconfig /sbin
popd

rm -rf perl-5.32.1
print_pck_and_dezip perl-5.32.1.tar.xz

pushd perl-5.32.1
	export BUILD_ZLIB=False
	export BUILD_BZIP2=0
	sh Configure -des                                \
		-Dprefix=/usr                                \
		-Dvendorprefix=/usr                          \
		-Dprivlib=/usr/lib/perl5/5.32/core_perl      \
		-Darchlib=/usr/lib/perl5/5.32/core_perl      \
		-Dsitelib=/usr/lib/perl5/5.32/site_perl      \
		-Dsitearch=/usr/lib/perl5/5.32/site_perl     \
		-Dvendorlib=/usr/lib/perl5/5.32/vendor_perl  \
		-Dvendorarch=/usr/lib/perl5/5.32/vendor_perl \
		-Dman1dir=/usr/share/man/man1                \
		-Dman3dir=/usr/share/man/man3                \
		-Dpager="/usr/bin/less -isR"                 \
		-Duseshrplib                                 \
		-Dusethreads
	make
	make test || read_input "perl"
	make install
	unset BUILD_ZLIB BUILD_BZIP2
popd


rm -rf XML-Parser-2.46
print_pck_and_dezip XML-Parser-2.46.tar.gz

pushd XML-Parser-2.46
	perl Makefile.PL
	make
	make test || read_input "tcl"
	make install
popd

rm -rf intltool-0.51.0
print_pck_and_dezip intltool-0.51.0.tar.gz

pushd intltool-0.51.0
	sed -i 's:\\\${:\\\$\\{:' intltool-update.in
	./configure --prefix=/usr
	make
	make check || read_input "intltool"
	make install
	install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
popd

rm -rf autoconf-2.71
print_pck_and_dezip autoconf-2.71.tar.xz

pushd autoconf-2.71
	# sed -i '361 s/{/\\{/' bin/autoscan.in
	./configure --prefix=/usr
	make
	make check || read_input "autoconf"
	make install
popd

rm -rf automake-1.16.3
print_pck_and_dezip automake-1.16.3.tar.xz

pushd automake-1.16.3
	sed -i "s/''/etags/" t/tags-lisp-space.sh
	./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.3
	make
	make -j4 check  || read_input "automake"
	make install
popd


rm -rf kmod-28
print_pck_and_dezip kmod-28.tar.xz

pushd kmod-28
	./configure --prefix=/usr \
		--bindir=/bin \
		--sysconfdir=/etc \
		--with-rootlibdir=/lib \
		--with-xz \
		--with-zstd \
		--with-zlib
	make
	make install
	for target in depmod insmod lsmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod /sbin/$target
	done
	ln -sfv kmod /bin/lsmod
popd

rm -rf elfutils-0.183
print_pck_and_dezip elfutils-0.183.tar.bz2

pushd elfutils-0.183
	./configure --prefix=/usr \
		--disable-debuginfod \
		--enable-libdebuginfod=dummy \
		--libdir=/lib
	make
	make check
	make -C libelf install
	install -vm644 config/libelf.pc /usr/lib/pkgconfig
	rm /lib/libelf.a
popd


rm -rf libffi-3.3
print_pck_and_dezip libffi-3.3.tar.gz

pushd libffi-3.3
	./configure --prefix=/usr --disable-static --with-gcc-arch=native
	make
	make check || read_input "libffi"
	make install
popd


rm -rf openssl-1.1.1j
print_pck_and_dezip openssl-1.1.1j.tar.gz

pushd openssl-1.1.1j
	./config --prefix=/usr \
		--openssldir=/etc/ssl \
		--libdir=lib \
		shared \
		zlib-dynamic
	make
	make test || read_input "openssl"
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install
	mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1j
	cp -vfr doc/* /usr/share/doc/openssl-1.1.1j
popd


rm -rf Python-3.9.2
print_pck_and_dezip Python-3.9.2.tar.xz

pushd Python-3.9.2
	./configure --prefix=/usr       \
		--enable-shared     \
		--with-system-expat \
		--with-system-ffi   \
		--with-ensurepip=yes
	make
	make test || read_input "python"
	make install
	# chmod -v 755 /usr/lib/libpython3.8.so
	# chmod -v 755 /usr/lib/libpython3.so
	# ln -sfv pip3.8 /usr/bin/pip3

	install -v -dm755 /usr/share/doc/python-3.9.2/html
	tar --strip-components=1  \
		--no-same-owner \
		--no-same-permissions \
		-C /usr/share/doc/python-3.9.2/html \
		-xvf ../python-3.9.2-docs-html.tar.bz2
popd



rm -rf ninja-1.10.2
print_pck_and_dezip ninja-1.10.2.tar.gz

pushd ninja-1.10.2
	export NINJAJOBS=4
	sed -i '/int Guess/a \
int   j = 0;\
char* jobs = getenv( "NINJAJOBS" );\
if ( jobs != NULL ) j = atoi( jobs );\
if ( j > 0 ) return j;\
' src/ninja.cc
	python3 configure.py --bootstrap
	./ninja ninja_test
	./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
	install -vm755 ninja /usr/bin/
	install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
	install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja
popd


rm -rf meson-0.57.1
print_pck_and_dezip meson-0.57.1.tar.gz

pushd meson-0.57.1
	python3 setup.py build
	python3 setup.py install --root=dest
	cp -rv dest/* /
popd

rm -rf coreutils-8.32
print_pck_and_dezip coreutils-8.32.tar.xz

pushd coreutils-8.32
	patch -Np1 -i ../coreutils-8.32-i18n-1.patch
	sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
	autoreconf -fiv
	FORCE_UNSAFE_CONFIGURE=1 ./configure \
		--prefix=/usr \
		--enable-no-install-program=kill,uptime
	make
	make NON_ROOT_USERNAME=tester check-root
	echo "dummy:x:102:tester" >> /etc/group
	chown -Rv tester .
	su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
	sed -i '/dummy/d' /etc/group
	make install
	mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
	mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
	mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
	mv -v /usr/bin/chroot /usr/sbin
	mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
	mv -v /usr/bin/{head,nice,sleep,touch} /bin
popd

rm -rf check-0.15.2
print_pck_and_dezip check-0.15.2.tar.gz

pushd check-0.15.2
	./configure --prefix=/usr --disable-static
	make
	make check || read_input "check"
	make docdir=/usr/share/doc/check-0.15.2 install
popd

rm -rf diffutils-3.7
print_pck_and_dezip diffutils-3.7.tar.xz

pushd diffutils-3.7
	./configure --prefix=/usr
	make
	make check || read_input "diffutils"
	make install
popd

rm -rf gawk-5.1.0
print_pck_and_dezip gawk-5.1.0.tar.xz

pushd gawk-5.1.0
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr
	make
	make check || read_input "gawk"
	make install
	mkdir -v /usr/share/doc/gawk-5.1.0
	cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0
popd


rm -rf findutils-4.7.0
print_pck_and_dezip findutils-4.7.0.tar.xz

pushd findutils-4.7.0
	./configure --prefix=/usr --localstatedir=/var/lib/locate
	make
	chown -Rv tester .
	su tester -c "PATH=$PATH make check" || read_input "findutils"
	make install
	mv -v /usr/bin/find /bin
	sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
popd

rm -rf groff-1.22.4
print_pck_and_dezip groff-1.22.4.tar.gz

pushd groff-1.22.4
	PAGE=A4 ./configure --prefix=/usr
	make -j1
	make install
popd

rm -rf grub-2.04
print_pck_and_dezip grub-2.04.tar.xz

pushd grub-2.04
	sed "s/gold-version/& -R .note.gnu.property/" \
		-i Makefile.in grub-core/Makefile.in
	./configure --prefix=/usr \
		--sbindir=/sbin \
		--sysconfdir=/etc \
		--disable-efiemu \
		--disable-werror
	make
	make install
	mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
popd


rm -rf less-563
print_pck_and_dezip less-563.tar.gz

pushd less-563
	./configure --prefix=/usr --sysconfdir=/etc
	make
	make install
popd

rm -rf gzip-1.10
print_pck_and_dezip gzip-1.10.tar.xz

pushd gzip-1.10
	./configure --prefix=/usr
	make
	make check || read_input "gzip"
	make install
	mv -v /usr/bin/gzip /bin
popd

rm -rf iproute2-5.10.0
print_pck_and_dezip iproute2-5.10.0.tar.xz

pushd iproute2-5.10.0
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8
	sed -i 's/.m_ipt.o//' tc/Makefile
	make
	make DOCDIR=/usr/share/doc/iproute2-5.10.0 install
popd


rm -rf kbd-2.4.0
print_pck_and_dezip kbd-2.4.0.tar.xz

pushd kbd-2.4.0
	patch -Np1 -i ../kbd-2.4.0-backspace-1.patch
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
	./configure --prefix=/usr --disable-vlock
	make
	make check || read_input "kbd"
	make install
	# rm -v /usr/lib/libtswrap.{a,la,so*}
	mkdir -v            /usr/share/doc/kbd-2.4.0
	cp -R -v docs/doc/* /usr/share/doc/kbd-2.4.0
popd

rm -rf libpipeline-1.5.3
print_pck_and_dezip libpipeline-1.5.3.tar.gz

pushd libpipeline-1.5.3
	./configure --prefix=/usr
	make
	make check || read_input "libpipeline"
	make install
popd


rm -rf make-4.3
print_pck_and_dezip make-4.3.tar.gz

pushd make-4.3
	./configure --prefix=/usr
	make
	make check || read_input "make"
	make install
popd


rm -rf patch-2.7.6
print_pck_and_dezip patch-2.7.6.tar.xz

pushd patch-2.7.6
	./configure --prefix=/usr
	make
	make check || read_input "patch"
	make install
popd


rm -rf man-db-2.9.4
print_pck_and_dezip man-db-2.9.4.tar.xz

pushd man-db-2.9.4
	# sed -i '/find/s@/usr@@' init/systemd/man-db.service.in
	./configure --prefix=/usr \
		--docdir=/usr/share/doc/man-db-2.9.4 \
		--sysconfdir=/etc \
		--disable-setuid \
		--enable-cache-owner=bin \
		--with-browser=/usr/bin/lynx \
		--with-vgrind=/usr/bin/vgrind \
		--with-grap=/usr/bin/grap \
		--with-systemdtmpfilesdir= \
		--with-systemdsystemunitdir=
	make
	make check || read_input "man-db"
	make install
popd


rm -rf tar-1.34
print_pck_and_dezip tar-1.34.tar.xz

pushd tar-1.34
	FORCE_UNSAFE_CONFIGURE=1  \
		./configure --prefix=/usr \
		--bindir=/bin
	make
	make check || read_input "tar"
	make install
	make -C doc install-html docdir=/usr/share/doc/tar-1.34
popd

rm -rf texinfo-6.7
print_pck_and_dezip texinfo-6.7.tar.xz

pushd texinfo-6.7
	./configure --prefix=/usr
	make
	make check || read_input "texinfo"
	make install
	make TEXMF=/usr/share/texmf install-tex
	pushd /usr/share/info
		rm -v dir
		for f in *
			do install-info $f dir 2>/dev/null
		done
	popd
popd


rm -rf vim-8.2.2433
print_pck_and_dezip vim-8.2.2433.tar.gz

pushd vim-8.2.2433
	echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
	./configure --prefix=/usr
	make
	chown -Rv tester .
	su tester -c "LANG=en_US.UTF-8 make -j1 test" &> vim-test.log
	make install
	ln -sv vim /usr/bin/vi
	for L in  /usr/share/man/{,*/}man1/vim.1; do
		ln -sv vim.1 $(dirname $L)/vi.1
	done
	ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.2433
	cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif
" End /etc/vimrc
EOF
popd

rm -rf eudev-3.2.10
print_pck_and_dezip eudev-3.2.10............................
pushd eudev-3.2.10
	./configure --prefix=/usr           \
		--bindir=/sbin          \
		--sbindir=/sbin         \
		--libdir=/usr/lib       \
		--sysconfdir=/etc       \
		--libexecdir=/lib       \
		--with-rootprefix=      \
		--with-rootlibdir=/lib  \
		--enable-manpages       \
		--disable-static
	make
	mkdir -pv /lib/udev/rules.d
	mkdir -pv /etc/udev/rules.d
	make check
	make install
	tar -xvf ../udev-lfs-20171102.tar.xz
	make -f udev-lfs-20171102/Makefile.lfs install
	udevadm hwdb --update
popd

# rm -rf systemd-246
# print_pck_and_dezip systemd-246.tar.gz

# pushd systemd-246
# 	ln -sf /bin/true /usr/bin/xsltproc
# 	tar -xf ../systemd-man-pages-246.tar.xz
# 	sed '177,$ d' -i src/resolve/meson.build
# 	sed -i 's/GROUP="render", //' rules.d/50-udev-default.rules.in

# 	mkdir -p build
# 	cd build
# 	LANG=en_US.UTF-8                    \
# 		meson --prefix=/usr                 \
# 		--sysconfdir=/etc             \
# 		--localstatedir=/var          \
# 		-Dblkid=true                  \
# 		-Dbuildtype=release           \
# 		-Ddefault-dnssec=no           \
# 		-Dfirstboot=false             \
# 		-Dinstall-tests=false         \
# 		-Dkmod-path=/bin/kmod         \
# 		-Dldconfig=false              \
# 		-Dmount-path=/bin/mount       \
# 		-Drootprefix=                 \
# 		-Drootlibdir=/lib             \
# 		-Dsplit-usr=true              \
# 		-Dsulogin-path=/sbin/sulogin  \
# 		-Dsysusers=false              \
# 		-Dumount-path=/bin/umount     \
# 		-Db_lto=false                 \
# 		-Drpmmacrosdir=no             \
# 		-Dhomed=false                 \
# 		-Duserdb=false                \
# 		-Dman=true                    \
# 		-Ddocdir=/usr/share/doc/systemd-246 \
# 		..
# 	LANG=en_US.UTF-8 ninja
# 	LANG=en_US.UTF-8 ninja install
# 	rm -f /usr/bin/xsltproc
# 	systemd-machine-id-setup
# 	systemctl preset-all
# 	systemctl disable systemd-time-wait-sync.service
# 	rm -f /usr/lib/sysctl.d/50-pid-max.conf
# popd


# rm -rf dbus-1.12.20
# print_pck_and_dezip dbus-1.12.20.tar.gz

# pushd dbus-1.12.20
# 	./configure --prefix=/usr                       \
# 		--sysconfdir=/etc                   \
# 		--localstatedir=/var                \
#         --disable-static                    \
#         --disable-doxygen-docs              \
#         --disable-xml-docs                  \
#         --docdir=/usr/share/doc/dbus-1.12.20 \
#         --with-console-auth-dir=/run/console
# 	make
# 	make install
# 	mv -v /usr/lib/libdbus-1.so.* /lib
# 	ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
# 	ln -sfv /etc/machine-id /var/lib/dbus
# 	sed -i 's:/var/run:/run:' /lib/systemd/system/dbus.socket
# popd

rm -rf procps-ng-3.3.17
print_pck_and_dezip procps-ng-3.3.17.tar.xz

pushd procps-ng-3.3.17
	./configure --prefix=/usr                            \
		--exec-prefix=                           \
		--libdir=/usr/lib                        \
		--docdir=/usr/share/doc/procps-ng-3.3.17 \
		--disable-static                         \
		--disable-kill
	make
	make check || read_input "procps-ng"
	make install
	mv -v /usr/lib/libprocps.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
popd


rm -rf util-linux-2.36.2
print_pck_and_dezip util-linux-2.36.2.tar.xz

pushd util-linux-2.36.2
	# mkdir -pv /var/lib/hwclock
	./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
		--docdir=/usr/share/doc/util-linux-2.36.2 \
		--disable-chfn-chsh  \
		--disable-login      \
		--disable-nologin    \
		--disable-su         \
		--disable-setpriv    \
		--disable-runuser    \
		--disable-pylibmount \
		--disable-static     \
		--without-python \
		--without-systemd    \
		--without-systemdsystemunitdir \
		runstatedir=/run
	make
	chown -Rv tester .
	su tester -c "make -k check" || read_input "util-linux"
	make install
popd



rm -rf e2fsprogs-1.46.1
print_pck_and_dezip e2fsprogs-1.46.1.tar.gz

pushd e2fsprogs-1.46.1
	mkdir -v build
	cd build
	../configure --prefix=/usr           \
		--bindir=/bin           \
		--with-root-prefix=""   \
		--enable-elf-shlibs     \
		--disable-libblkid      \
		--disable-libuuid       \
		--disable-uuidd         \
		--disable-fsck
	make
	make check || read_input "e2fsprogs"
	make install
	rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
	# chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
	gunzip -v /usr/share/info/libext2fs.info.gz
	install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
	makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
	install -v -m644 doc/com_err.info /usr/share/info
	install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
popd

rm -rf sysklogd-1.5.1
print_pck_and_dezip sysklogd-1.5.1.............

pushd sysklogd-1.5.1
	sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
	sed -i 's/union wait/int/' syslogd.c
	make
	make BINDIR=/sbin install
	cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
# End /etc/syslog.conf
EOF
popd

rm -rf sysvinit-2.98
print_pck_and_dezip sysvinit-2.98.........................

pushd sysvinit-2.98
	patch -Np1 -i ../sysvinit-2.98-consolidated-1.patch
	make
	make install
	save_lib="ld-2.33.so libc-2.33.so libpthread-2.33.so libthread_db-1.0.so"
	cd /lib
	for LIB in $save_lib; do
		objcopy --only-keep-debug $LIB $LIB.dbg
		strip --strip-unneeded $LIB
		objcopy --add-gnu-debuglink=$LIB.dbg $LIB
	done
	save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.28
		libitm.so.1.0.0 libatomic.so.1.2.0"
	cd /usr/lib
	for LIB in $save_usrlib; do
		objcopy --only-keep-debug $LIB $LIB.dbg
		strip --strip-unneeded $LIB
		objcopy --add-gnu-debuglink=$LIB.dbg $LIB
	done
	unset LIB save_lib save_usrlib
	find /usr/lib -type f -name \*.a \
		-exec strip --strip-debug {} ';'
	find /lib /usr/lib -type f -name \*.so* ! -name \*dbg \
		-exec strip --strip-unneeded {} ';'
	find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
		-exec strip --strip-all {} ';'
	rm -rf /tmp/*
popd
