#!/bin/bash

# exit if script fail
set -e

print_pck_and_dezip() {
	echo $1
	tar -xf $1
}

pass_function() {


rm -rf man-pages-5.08
print_pck_and_dezip man-pages-5.08.tar.xz
pushd man-pages-5.08
	make install
popd

rm -rf tcl8.6.10
print_pck_and_dezip tcl8.6.10-src.tar.gz
pushd tcl8.6.10
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
#	make test
	make install
	chmod -v u+w /usr/lib/libtcl8.6.so
	make install-private-headers
	ln -sfv tclsh8.6 /usr/bin/tclsh
popd

rm -rf expect5.45.4
print_pck_and_dezip expect5.45.4.tar.gz
pushd expect5.45.4
	./configure --prefix=/usr --with-tcl=/usr/lib --enable-shared --mandir=/usr/share/man --with-tclinclude=/usr/include
	make
#	make test
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
#	make check
popd


rm -rf iana-etc-20200821
print_pck_and_dezip iana-etc-20200821.tar.gz

pushd iana-etc-20200821
	 cp services protocols /etc
popd

rm -rf glibc-2.32
print_pck_and_dezip glibc-2.32.tar.xz

pushd glibc-2.32
	 patch -Np1 -i ../glibc-2.32-fhs-1.patch
	 mkdir -v build
	 cd build

	 ../configure --prefix=/usr                   \
		 --disable-werror                         \
		 --enable-kernel=3.2                      \
		 --enable-stack-protector=strong          \
		 --with-headers=/usr/include              \
		 libc_cv_slibdir=/lib
	 make
	 case $(uname -m) in
		 i?86)   ln -sfnv $PWD/elf/ld-linux.so.2        /lib ;;
		 x86_64) ln -sfnv $PWD/elf/ld-linux-x86-64.so.2 /lib ;;
	 esac
	 
#	 make check
	 touch /etc/ld.so.conf
	 sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
	 make install
	 cp -v ../nscd/nscd.conf /etc/nscd.conf
	 mkdir -pv /var/cache/nscd
	 install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
	 install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
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
	 tar -xf ../../tzdata2020a.tar.gz
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
#	 make check
	 make install
	 mv -v /usr/lib/libz.so.* /lib
	 ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
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
	 ln -svf ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
	 rm -v /usr/bin/{bunzip2,bzcat,bzip2}
	 ln -svf bzip2 /bin/bunzip2
	 ln -svf bzip2 /bin/bzcat
popd


rm -rf xz-5.2.5
print_pck_and_dezip xz-5.2.5.tar.xz

pushd xz-5.2.5
	./configure --prefix=/usr    \
		--disable-static		 \
		--docdir=/usr/share/doc/xz-5.2.5
	make
#	make check
	make install
	mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
	mv -v /usr/lib/liblzma.so.* /lib
	ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
popd


rm -rf zstd-1.4.5
print_pck_and_dezip zstd-1.4.5.tar.gz

pushd zstd-1.4.5
	make
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
#	make check
	make install
popd


rm -rf readline-8.0
print_pck_and_dezip readline-8.0.tar.gz

pushd readline-8.0
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
	./configure --prefix=/usr    \
		--disable-static \
		--with-curses    \
		--docdir=/usr/share/doc/readline-8.0
	make SHLIB_LIBS="-lncursesw"
	make SHLIB_LIBS="-lncursesw" install
	mv -v /usr/lib/lib{readline,history}.so.* /lib
	chmod -v u+w /lib/lib{readline,history}.so.*
	ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
	ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
	install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.0
popd

rm -rf m4-1.4.18
print_pck_and_dezip m4-1.4.18.tar.xz

pushd m4-1.4.18
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
	./configure --prefix=/usr
	make
#	make check
	make install
popd


rm -rf bc-3.1.5
print_pck_and_dezip bc-3.1.5.tar.xz

pushd bc-3.1.5
	PREFIX=/usr CC=gcc CFLAGS="-std=c99" ./configure.sh -G -O3
	make
#	make test
	make install
popd


rm -rf flex-2.6.4
print_pck_and_dezip flex-2.6.4.tar.gz

pushd flex-2.6.4
	./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
	make
#	make check
	make install
	ln -sv flex /usr/bin/lex
popd

rm -rf binutils-2.35
print_pck_and_dezip binutils-2.35.tar.xz

pushd binutils-2.35
	expect -c "spawn ls"
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
#	make -k check
	make tooldir=/usr install
popd

rm -rf gmp-6.2.0
print_pck_and_dezip gmp-6.2.0.tar.xz

pushd gmp-6.2.0
	./configure --prefix=/usr    \
		--enable-cxx     \
        --disable-static \
        --docdir=/usr/share/doc/gmp-6.2.0
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
	./configure --prefix=/usr        \
		--disable-static     \
        --enable-thread-safe \
        --docdir=/usr/share/doc/mpfr-4.1.0
	make
	make html
#	make check
	make install
	make install-html
popd

rm -rf mpc-1.1.0
print_pck_and_dezip mpc-1.1.0.tar.gz

pushd mpc-1.1.0
	./configure --prefix=/usr    \
		--disable-static \
		--docdir=/usr/share/doc/mpc-1.1.0
	make
	make html
#	make check
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
#	make check
	make install
	mv -v /usr/lib/libattr.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
popd

rm -rf acl-2.2.53
print_pck_and_dezip acl-2.2.53.tar.gz

pushd acl-2.2.53
	./configure --prefix=/usr         \
		--disable-static      \
        --libexecdir=/usr/lib \
        --docdir=/usr/share/doc/acl-2.2.53
	make
	make install
	mv -v /usr/lib/libacl.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
popd

rm -rf libcap-2.42
print_pck_and_dezip libcap-2.42.tar.xz

pushd libcap-2.42
	sed -i '/install -m.*STACAPLIBNAME/d' libcap/Makefile
	make lib=lib
#	make test
	make lib=lib PKGCONFIGDIR=/usr/lib/pkgconfig install
	chmod -v 755 /lib/libcap.so.2.42
	mv -v /lib/libpsx.a /usr/lib
	rm -v /lib/libcap.so
	ln -sfv ../../lib/libcap.so.2 /usr/lib/libcap.so
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
	sed -i 's/1000/999/' etc/useradd
	touch /usr/bin/passwd
	./configure --sysconfdir=/etc \
		--with-group-name-max-length=32
	make
	make install
	pwconv
	grpconv
	sed -i 's/yes/no/' /etc/default/useradd
	echo "password" | passwd root
popd


rm -rf gcc-10.2.0
print_pck_and_dezip gcc-10.2.0.tar.xz

pushd gcc-10.2.0
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' \
				-i.orig gcc/config/i386/t-linux64
	;; esac
	mkdir -v build
	cd build
	../configure --prefix=/usr            \
		LD=ld                    \
		--enable-languages=c,c++ \
		--disable-multilib       \
		--disable-bootstrap      \
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
	install -v -dm755 /usr/lib/bfd-plugins
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
	rm -v dummy.c a.out dummy.log
	mkdir -pv /usr/share/gdb/auto-load/usr/lib
	mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
	read -p "Press enter to continue..."
popd
     

rm -rf pkg-config-0.29.2
print_pck_and_dezip pkg-config-0.29.2.tar.gz

pushd pkg-config-0.29.2
	./configure --prefix=/usr              \
		--with-internal-glib       \
		--disable-host-tool        \
		--docdir=/usr/share/doc/pkg-config-0.29.2
	make
#	make check
	make install
popd

rm -rf ncurses-6.2
print_pck_and_dezip ncurses-6.2.tar.gz

pushd ncurses-6.2
	sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
	./configure --prefix=/usr           \
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
		rm -vf                    /usr/lib/lib${lib}.so
		echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
		ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
	done
	rm -vf                     /usr/lib/libcursesw.so
	echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
	ln -sfv libncurses.so      /usr/lib/libcurses.so
	mkdir -v       /usr/share/doc/ncurses-6.2
	cp -v -R doc/* /usr/share/doc/ncurses-6.2
popd

rm -rf sed-4.8
print_pck_and_dezip sed-4.8.tar.xz

pushd sed-4.8
	./configure --prefix=/usr --bindir=/bin
	make
	make html
	chown -Rv tester .
#	su tester -c "PATH=$PATH make check"
	make install
	install -d -m755           /usr/share/doc/sed-4.8
	install -m644 doc/sed.html /usr/share/doc/sed-4.8
popd


rm -rf psmisc-23.3
print_pck_and_dezip psmisc-23.3.tar.xz

pushd psmisc-23.3
	./configure --prefix=/usr
	make
	make install
	mv -v /usr/bin/fuser   /bin
	mv -v /usr/bin/killall /bin
popd

rm -rf gettext-0.21
print_pck_and_dezip gettext-0.21.tar.xz

pushd gettext-0.21
	./configure --prefix=/usr    \
		--disable-static \
        --docdir=/usr/share/doc/gettext-0.21
	make
#	make check
	make install
	chmod -v 0755 /usr/lib/preloadable_libintl.so
popd

rm -rf bison-3.7.1
print_pck_and_dezip bison-3.7.1.tar.xz

pushd bison-3.7.1
	./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.1
	make
#	make check
	make install
popd

rm -rf grep-3.4
print_pck_and_dezip grep-3.4.tar.xz

pushd grep-3.4
	./configure --prefix=/usr --bindir=/bin
	make
#	make check
	make install
popd


rm -rf bash-5.0
print_pck_and_dezip bash-5.0.tar.gz

pushd bash-5.0
	patch -Np1 -i ../bash-5.0-upstream_fixes-1.patch
	./configure --prefix=/usr                    \
		--docdir=/usr/share/doc/bash-5.0 \
		--without-bash-malloc            \
		--with-installed-readline
	make
	chown -Rv tester .
	su tester << EOF
PATH=$PATH make tests < $(tty)
EOF
	make install
	mv -vf /usr/bin/bash /bin
	exec /bin/bash --login +h
popd
}

rm -rf libtool-2.4.6
print_pck_and_dezip libtool-2.4.6.tar.xz

pushd libtool-2.4.6
	./configure --prefix=/usr
	make
#	make check
	make install
popd

rm -rf gdbm-1.18.1
print_pck_and_dezip gdbm-1.18.1.tar.gz

pushd gdbm-1.18.1
	sed -r -i '/^char.*parseopt_program_(doc|args)/d' src/parseopt.c
	./configure --prefix=/usr    \
		--disable-static \
        --enable-libgdbm-compat
	make
#	make check
	make install
popd

rm -rf gperf-3.1
print_pck_and_dezip gperf-3.1.tar.gz

pushd gperf-3.1
	./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
	make
#	make -j1 check
	make install
popd


rm -rf expat-2.2.9
print_pck_and_dezip expat-2.2.9.tar.xz

pushd expat-2.2.9
	./configure --prefix=/usr    \
		--disable-static \
		--docdir=/usr/share/doc/expat-2.2.9
	make
#	make check
	make install
	install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.9
popd


rm -rf inetutils-1.9.4
print_pck_and_dezip inetutils-1.9.4.tar.xz

pushd inetutils-1.9.4
	./configure --prefix=/usr        \
		--localstatedir=/var \
		--disable-logger     \
		--disable-whois      \
		--disable-rcp        \
		--disable-rexec      \
		--disable-rlogin     \
		--disable-rsh        \
		--disable-servers
	make
#	make check
	make install
	mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
	mv -v /usr/bin/ifconfig /sbin
popd



rm -rf perl-5.32.0
print_pck_and_dezip perl-5.32.0.tar.xz

pushd perl-5.32.0
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
#	make test
	make install
	unset BUILD_ZLIB BUILD_BZIP2
popd


rm -rf XML-Parser-2.46
print_pck_and_dezip XML-Parser-2.46.tar.gz

pushd XML-Parser-2.46
	perl Makefile.PL
	make
#	make test
	make install
popd

rm -rf intltool-0.51.0
print_pck_and_dezip intltool-0.51.0.tar.gz

pushd intltool-0.51.0
	sed -i 's:\\\${:\\\$\\{:' intltool-update.in
	./configure --prefix=/usr
	make
#	make check
	make install
	install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
popd

rm -rf autoconf-2.69
print_pck_and_dezip autoconf-2.69.tar.xz

pushd autoconf-2.69
	sed -i '361 s/{/\\{/' bin/autoscan.in
	./configure --prefix=/usr
	make
#	make check
	make install
popd

rm -rf automake-1.16.2
print_pck_and_dezip automake-1.16.2.tar.xz

pushd automake-1.16.2
	sed -i "s/''/etags/" t/tags-lisp-space.sh
	./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.2
	make
#	make -j4 check
	make install
popd


rm -rf kmod-27
print_pck_and_dezip kmod-27.tar.xz

pushd kmod-27
	./configure --prefix=/usr          \
		--bindir=/bin          \
        --sysconfdir=/etc      \
        --with-rootlibdir=/lib \
        --with-xz              \
		--with-zlib
	make
	make install
	for target in depmod insmod lsmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod /sbin/$target
	done
	ln -sfv kmod /bin/lsmod
popd

rm -rf elfutils-0.180
print_pck_and_dezip elfutils-0.180.tar.bz2

pushd elfutils-0.180
	./configure --prefix=/usr --disable-debuginfod --libdir=/lib
	make
#	make check
	make -C libelf install
	install -vm644 config/libelf.pc /usr/lib/pkgconfig
	rm /lib/libelf.a
popd


rm -rf libffi-3.3
print_pck_and_dezip libffi-3.3.tar.gz

pushd libffi-3.3
	./configure --prefix=/usr --disable-static --with-gcc-arch=native
	make
#	make check
	make install
popd


rm -rf openssl-1.1.1g
print_pck_and_dezip openssl-1.1.1g.tar.gz

pushd openssl-1.1.1g
	./config --prefix=/usr         \
		--openssldir=/etc/ssl \
        --libdir=lib          \
        shared                \
        zlib-dynamic
	make
#	make test
	sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
	make MANSUFFIX=ssl install
	mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1g
	cp -vfr doc/* /usr/share/doc/openssl-1.1.1g
popd


rm -rf Python-3.8.5
print_pck_and_dezip Python-3.8.5.tar.xz

pushd Python-3.8.5
	./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
	make
	make install
	chmod -v 755 /usr/lib/libpython3.8.so
	chmod -v 755 /usr/lib/libpython3.so
	ln -sfv pip3.8 /usr/bin/pip3

	install -v -dm755 /usr/share/doc/python-3.8.5/html
	tar --strip-components=1  \
		--no-same-owner       \
		--no-same-permissions \
		-C /usr/share/doc/python-3.8.5/html \
		-xvf ../python-3.8.5-docs-html.tar.bz2
popd



rm -rf ninja-1.10.0
print_pck_and_dezip ninja-1.10.0.tar.gz

pushd ninja-1.10.0
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


rm -rf meson-0.55.0
print_pck_and_dezip meson-0.55.0.tar.gz

pushd meson-0.55.0
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
#	su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
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
#	make check
	make docdir=/usr/share/doc/check-0.15.2 install
popd

rm -rf diffutils-3.7
print_pck_and_dezip diffutils-3.7.tar.xz

pushd diffutils-3.7
	./configure --prefix=/usr
	make
#	make check
	make install
popd

rm -rf gawk-5.1.0
print_pck_and_dezip gawk-5.1.0.tar.xz

pushd gawk-5.1.0
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr
	make
#	make check
	make install
	mkdir -vf /usr/share/doc/gawk-5.1.0
	cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0
popd


rm -rf findutils-4.7.0
print_pck_and_dezip findutils-4.7.0.tar.xz

pushd findutils-4.7.0
	./configure --prefix=/usr --localstatedir=/var/lib/locate
	make
	chown -Rv tester .
#	su tester -c "PATH=$PATH make check"
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
	./configure --prefix=/usr          \
		--sbindir=/sbin        \
        --sysconfdir=/etc      \
        --disable-efiemu       \
        --disable-werror
	make
	make install
	mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
popd


rm -rf less-551
print_pck_and_dezip less-551.tar.gz

pushd less-551
	./configure --prefix=/usr --sysconfdir=/etc
	make
	make install
popd

rm -rf gzip-1.10
print_pck_and_dezip gzip-1.10.tar.xz

pushd gzip-1.10
	./configure --prefix=/usr
	make
#	make check
	make install
	mv -v /usr/bin/gzip /bin
popd

rm -rf iproute2-5.8.0
print_pck_and_dezip iproute2-5.8.0.tar.xz

pushd iproute2-5.8.0
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8
	sed -i 's/.m_ipt.o//' tc/Makefile
	make
	make DOCDIR=/usr/share/doc/iproute2-5.8.0 install
popd


rm -rf kbd-2.3.0
print_pck_and_dezip kbd-2.3.0.tar.xz

pushd kbd-2.3.0
	patch -Np1 -i ../kbd-2.3.0-backspace-1.patch
	sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
	sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
	./configure --prefix=/usr --disable-vlock
	make
#	make check
	make install
	rm -v /usr/lib/libtswrap.{a,la,so*}
	mkdir -vf            /usr/share/doc/kbd-2.3.0
	cp -R -v docs/doc/* /usr/share/doc/kbd-2.3.0
popd

rm -rf libpipeline-1.5.3
print_pck_and_dezip libpipeline-1.5.3.tar.gz

pushd libpipeline-1.5.3
	./configure --prefix=/usr
	make
#	make check
	make install
popd


rm -rf make-4.3
print_pck_and_dezip make-4.3.tar.gz

pushd make-4.3
	./configure --prefix=/usr
	make
#	make check
	make install
popd


rm -rf patch-2.7.6
print_pck_and_dezip patch-2.7.6.tar.xz

pushd patch-2.7.6
	./configure --prefix=/usr
	make
#	make check
	make install
popd


rm -rf man-db-2.9.3
print_pck_and_dezip man-db-2.9.3.tar.xz

pushd man-db-2.9.3
	sed -i '/find/s@/usr@@' init/systemd/man-db.service.in
	./configure --prefix=/usr                        \
		--docdir=/usr/share/doc/man-db-2.9.3 \
        --sysconfdir=/etc                    \
        --disable-setuid                     \
        --enable-cache-owner=bin             \
        --with-browser=/usr/bin/lynx         \
        --with-vgrind=/usr/bin/vgrind        \
        --with-grap=/usr/bin/grap
	make
#	make check
	make install
popd


rm -rf tar-1.32
print_pck_and_dezip tar-1.32.tar.xz

pushd tar-1.32
	FORCE_UNSAFE_CONFIGURE=1  \
		./configure --prefix=/usr \
		--bindir=/bin
	make
#	make check
	make install
	make -C doc install-html docdir=/usr/share/doc/tar-1.32
popd

rm -rf texinfo-6.7
print_pck_and_dezip texinfo-6.7.tar.xz

pushd texinfo-6.7
	./configure --prefix=/usr --disable-static
	make
#	make check
	make install
	make TEXMF=/usr/share/texmf install-tex
	pushd /usr/share/info
		rm -v dir
		for f in *
			do install-info $f dir 2>/dev/null
		done
	popd
popd


rm -rf vim-8.2.1361
print_pck_and_dezip vim-8.2.1361.tar.gz

pushd vim-8.2.1361
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
	ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.1361
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
	vim
popd


rm -rf systemd-246
print_pck_and_dezip systemd-246.tar.gz

pushd systemd-246
	ln -sf /bin/true /usr/bin/xsltproc
	tar -xf ../systemd-man-pages-246.tar.xz
	sed '177,$ d' -i src/resolve/meson.build
	sed -i 's/GROUP="render", //' rules.d/50-udev-default.rules.in

	mkdir -p build
	cd build
	LANG=en_US.UTF-8                    \
		meson --prefix=/usr                 \
		--sysconfdir=/etc             \
		--localstatedir=/var          \
		-Dblkid=true                  \
		-Dbuildtype=release           \
		-Ddefault-dnssec=no           \
		-Dfirstboot=false             \
      	-Dinstall-tests=false         \
      	-Dkmod-path=/bin/kmod         \
      	-Dldconfig=false              \
      	-Dmount-path=/bin/mount       \
      	-Drootprefix=                 \
      	-Drootlibdir=/lib             \
      	-Dsplit-usr=true              \
      	-Dsulogin-path=/sbin/sulogin  \
      	-Dsysusers=false              \
      	-Dumount-path=/bin/umount     \
      	-Db_lto=false                 \
      	-Drpmmacrosdir=no             \
      	-Dhomed=false                 \
      	-Duserdb=false                \
      	-Dman=true                    \
      	-Ddocdir=/usr/share/doc/systemd-246 \
		..
	LANG=en_US.UTF-8 ninja
	LANG=en_US.UTF-8 ninja install
	rm -f /usr/bin/xsltproc
	systemd-machine-id-setup
	systemctl preset-all
	systemctl disable systemd-time-wait-sync.service
	rm -f /usr/lib/sysctl.d/50-pid-max.conf
popd


rm -rf dbus-1.12.20
print_pck_and_dezip dbus-1.12.20.tar.gz

pushd dbus-1.12.20
	./configure --prefix=/usr                       \
		--sysconfdir=/etc                   \
		--localstatedir=/var                \
        --disable-static                    \
        --disable-doxygen-docs              \
        --disable-xml-docs                  \
        --docdir=/usr/share/doc/dbus-1.12.20 \
        --with-console-auth-dir=/run/console
	make
	make install
	mv -v /usr/lib/libdbus-1.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
	ln -sfv /etc/machine-id /var/lib/dbus
	sed -i 's:/var/run:/run:' /lib/systemd/system/dbus.socket
popd

rm -rf procps-ng-3.3.16
print_pck_and_dezip procps-ng-3.3.16.tar.xz

pushd procps-ng-3.3.16
	./configure --prefix=/usr                            \
		--exec-prefix=                           \
		--libdir=/usr/lib                        \
		--docdir=/usr/share/doc/procps-ng-3.3.16 \
		--disable-static                         \
		--disable-kill                           \
		--with-systemd
	make
#	make check
	make install
	mv -v /usr/lib/libprocps.so.* /lib
	ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
popd


rm -rf util-linux-2.36
print_pck_and_dezip util-linux-2.36.tar.xz

pushd util-linux-2.36
	mkdir -pv /var/lib/hwclock
	./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
		--docdir=/usr/share/doc/util-linux-2.36 \
		--disable-chfn-chsh  \
		--disable-login      \
		--disable-nologin    \
		--disable-su         \
		--disable-setpriv    \
		--disable-runuser    \
		--disable-pylibmount \
		--disable-static     \
		--without-python
	make
	chown -Rv tester .
#	su tester -c "make -k check"
	make install
popd



rm -rf e2fsprogs-1.45.6
print_pck_and_dezip e2fsprogs-1.45.6.tar.gz

pushd e2fsprogs-1.45.6
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
#	make check
	make install
	chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
	gunzip -v /usr/share/info/libext2fs.info.gz
	install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
	makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
	install -v -m644 doc/com_err.info /usr/share/info
	install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
	rm -rf /tmp/*
popd
