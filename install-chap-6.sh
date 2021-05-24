#!/bin/bash

set -e

echo "Binutils"
tar -xf binutils-2.36.1.tar.xz
pushd binutils-2.36.1
	mkdir -p build && cd build
	../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT -disable-nls --disable-werror
	make
	make install
popd
rm -rf binutils-2.35

echo "gcc"
tar -xf gcc-10.2.0.tar.xz

pushd gcc-10.2.0
	tar -xf ../mpfr-4.1.0.tar.xz
	mv -v mpfr-4.1.0 mpfr
	tar -xf ../gmp-6.2.1.tar.xz
	mv -v gmp-6.2.1 gmp
	tar -xf ../mpc-1.2.1.tar.gz
	mv -v mpc-1.2.1 mpc
	sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
	mkdir -p build && cd build
	../configure --target=$LFS_TGT --prefix=$LFS/tools --with-glibc-version=2.11 --with-sysroot=$LFS --with-newlib --without-headers --enable-initfini-array --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
	make
	make install
	cd ..
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
popd

echo "Linux 5.10.17"
tar -xf linux-5.10.17.tar.xz
pushd linux-5.10.17
	make mrproper
	make headers
	find usr/include -name '.*' -delete
	rm usr/include/Makefile
	cp -rv usr/include $LFS/usr
popd

echo "glibc"
tar -xf glibc-2.33.tar.xz
pushd glibc-2.33
	ln -sfv ../../lib/ld-linux-x86-64.so.2 $LFS/lib64
	ln -sfv ../../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
	patch -Np1 -i ../glibc-2.32-fhs-1.patch
	mkdir -p build && cd build
	../configure --prefix=/usr --host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=3.2 --with-headers=$LFS/usr/include libc_cv_slibdir=/lib
	make
	make DESTDIR=$LFS install
	$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders
popd

tar -xf gcc-10.2.0.tar.xz
pushd gcc-10.2.0
	mkdir -p build && cd build
	../libstdc++-v3/configure --host=$LFS_TGT --build=$(../config.guess) --prefix=/usr --disable-multilib --disable-nls --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0
	make
	make DESTDIR=$LFS install
popd

echo "m4"
tar -xf m4-1.4.18.tar.xz
pushd m4-1.4.18
	sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
	echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd

echo "ncurses"
tar -xf ncurses-6.2.tar.gz
pushd ncurses-6.2
	sed -i s/mawk// configure
	mkdir build
	pushd build
		../configure
		make -C include
		make -C progs tic
	popd
	./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) --mandir=/usr/share/man --with-manpage-format=normal --with-shared --without-debug --without-ada --without-normal --enable-widec
	make
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
	echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
	mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
	ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so
popd

echo "bash"
tar -xf bash-5.1.tar.gz
pushd bash-5.1
	./configure --prefix=/usr --build=$(support/config.guess) --host=$LFS_TGT --without-bash-malloc
	make
	make DESTDIR=$LFS install
	mv $LFS/usr/bin/bash $LFS/bin/bash
	ln -sv bash $LFS/bin/sh
popd

echo "coreutils" # 59
tar -xf coreutils-8.32.tar.xz
pushd coreutils-8.32
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
	mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin
	mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin
	mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin
	mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8
popd

echo "diffutils"
tar -xf diffutils-3.7.tar.xz
pushd diffutils-3.7
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
popd

echo "file"
tar -xf file-5.39.tar.gz
pushd file-5.39
	mkdir build
	cd build
	../configure --disable-bzlib \
		--disable-libseccomp --disable-xzlib --disable-zlib
	make
	cd ..
	./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
	make FILE_COMPILE=$(pwd)/build/src/file
	make DESTDIR=$LFS install
popd

echo "findutils"
tar -xf findutils-4.7.0.tar.xz
pushd findutils-4.7.0
	./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/find $LFS/bin
	sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
popd

echo "gawk"
tar -xf gawk-5.1.0.tar.xz
pushd gawk-5.1.0
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
	make
	make DESTDIR=$LFS install
popd

echo "grep"
tar -xf grep-3.4.tar.xz
pushd grep-3.4
	./configure --prefix=/usr --host=$LFS_TGT --bindir=/bin
	make
	make DESTDIR=$LFS install
popd

echo "gzip"
tar -xf gzip-1.10.tar.xz
pushd gzip-1.10
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/gzip $LFS/bin
popd

echo "make"
tar -xf make-4.3.tar.gz
pushd make-4.3
	./configure --prefix=/usr \
		--without-guile \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd

echo "patch"
tar -xf patch-2.7.6.tar.xz
pushd patch-2.7.6
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd

echo "sed"
tar -xf sed-4.8.tar.xz
pushd sed-4.8
	./configure --prefix=/usr --host=$LFS_TGT --bindir=/bin
	make
	make DESTDIR=$LFS install
popd

echo "tar"
tar -xf tar-1.34.tar.xz
pushd tar-1.34
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		--bindir=/bin
	make
	make DESTDIR=$LFS install
popd

echo "xz"
tar -xf xz-5.2.5.tar.xz
pushd xz-5.2.5
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		--disable-static \
		--docdir=/usr/share/doc/xz-5.2.5
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin
	mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib
	ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) \
		$LFS/usr/lib/liblzma.so
popd

echo "binutils"
tar -xf binutils-2.36.1.tar.xz
pushd binutils-2.36.1
	mkdir -p build && cd build
	../configure --prefix=/usr \
		--build=$(../config.guess) \
		--host=$LFS_TGT \
		--disable-nls \
		--enable-shared \
		--disable-werror \
		--enable-64-bit-bfd
	make
	make DESTDIR=$LFS install
	install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
popd

echo "gcc - 2"
rm -rf gcc-10.2.0
tar -xf gcc-10.2.0.tar.xz
pushd gcc-10.2.0
	tar -xf ../mpfr-4.1.0.tar.xz
	mv -v mpfr-4.1.0 mpfr
	tar -xf ../gmp-6.2.1.tar.xz
	mv -v gmp-6.2.1 gmp
	tar -xf ../mpc-1.2.1.tar.gz
	mv -v mpc-1.2.1 mpc

	sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

	mkdir -v build
	cd build
	mkdir -pv $LFS_TGT/libgcc
	ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h

	../configure \
		--build=$(../config.guess) \
		--host=$LFS_TGT \
		--prefix=/usr \
		CC_FOR_TARGET=$LFS_TGT-gcc \
		--with-build-sysroot=$LFS \
		--enable-initfini-array \
		--disable-nls \
		--disable-multilib \
		--disable-decimal-float \
		--disable-libatomic \
		--disable-libgomp \
		--disable-libquadmath \
		--disable-libssp \
		--disable-libvtv \
		--disable-libstdcxx \
		--enable-languages=c,c++
	make
	make DESTDIR=$LFS install
	ln -sv gcc $LFS/usr/bin/cc
popd
