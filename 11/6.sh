#!/bin/bash

echo "M4"
tar -xf m4-1.4.19.tar.xz
pushd m4-1.4.19
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd
rm -rf m4-1.4.19

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
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess) \
		--mandir=/usr/share/man \
		--with-manpage-format=normal \
		--with-shared \
		--without-debug \
		--without-ada \
		--without-normal \
		--enable-widec
	make
	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
	echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
popd
rm -rf ncurses-6.2

echo "Bash"
tar -xf bash-5.1.8.tar.gz
pushd bash-5.1.8
	./configure --prefix=/usr \
		--build=$(support/config.guess) \
		--host=$LFS_TGT \
		--without-bash-malloc
	make
	make DESTDIR=$LFS install
	ln -sv bash $LFS/bin/sh
popd
rm -rf bash-5.1.8

echo "Coreutils"
tar -xf coreutils-8.32.tar.xz
pushd coreutils-8.32
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		--enable-install-program=hostname \
		--enable-no-install-program=kill,uptime
	make
	make DESTDIR=$LFS install
	mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
	mkdir -pv $LFS/usr/share/man/man8
	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
	sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
popd
rm -rf coreutils-8.32

echo "Diffutils"
tar -xf diffutils-3.8.tar.xz
pushd diffutils-3.8
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
popd
rm -rf diffutils-3.8

echo "File"
tar -xf file-5.40.tar.gz
pushd file-5.40
	mkdir build
	pushd build
		../configure --disable-bzlib \
			--disable-libseccomp \
			--disable-xzlib \
			--disable-zlib
		make
	popd
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess)
	make FILE_COMPILE=$(pwd)/build/src/file
	make DESTDIR=$LFS install
popd
rm -rf file-5.40

echo "Findutils"
tar -xf findutils-4.8.0.tar.xz
pushd findutils-4.8.0
	./configure --prefix=/usr \
		--localstatedir=/var/lib/locate \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd
rm -rf findutils-4.8.0

echo "Gawk"
tar -xf gawk-5.1.0.tar.xz
pushd gawk-5.1.0
	sed -i 's/extras//' Makefile.in
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(./config.guess)
	make
	make DESTDIR=$LFS install
popd
rm -rf gawk-5.1.0

echo "Grep"
tar -xf grep-3.7.tar.xz
pushd grep-3.7
	./configure --prefix=/usr \
		--host=$LFS_TGT
	make
	make DESTDIR=$LFS install
popd
rm -rf grep-3.7

echo "Gzip"
tar -xf gzip-1.10.tar.xz
pushd gzip-1.10
	./configure --prefix=/usr --host=$LFS_TGT
	make
	make DESTDIR=$LFS install
popd
rm -rf gzip-1.10

echo "Make"
tar -xf make-4.3.tar.gz
pushd make-4.3
	./configure --prefix=/usr \
		--without-guile \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd
rm -rf make-4.3

echo "Patch"
tar -xf patch-2.7.6.tar.xz
pushd patch-2.7.6
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd
rm -rf patch-2.7.6

echo "sed"
tar -xf sed-4.8.tar.xz
pushd sed-4.8
	./configure --prefix=/usr \
		--host=$LFS_TGT
	make
	make DESTDIR=$LFS install
popd
rm -rf sed-4.8

echo "tar"
tar -xf tar-1.34.tar.xz
pushd tar-1.34
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess)
	make
	make DESTDIR=$LFS install
popd
rm -rf tar-1.34

echo "Xz"
tar -xf xz-5.2.5.tar.xz
pushd xz-5.2.5
	./configure --prefix=/usr \
		--host=$LFS_TGT \
		--build=$(build-aux/config.guess) \
		--disable-static \
		--docdir=/usr/share/doc/xz-5.2.5
	make
	make DESTDIR=$LFS install
popd
rm -rf xz-5.2.5

echo "Binutils - pass 2"
tar -xf binutils-2.37.tar.xz
pushd binutils-2.37
	mkdir -v build
	pushd build
		../configure \
			--prefix=/usr \
			--build=$(../config.guess) \
			--host=$LFS_TGT \
			--disable-nls \
			--enable-shared \
			--disable-werror \
			--enable-64-bit-bfd
		make
		make DESTDIR=$LFS install -j1
		install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
popd
rm -rf binutils-2.37

echo "GCC - pass 2"
tar -xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
	tar -xf ../mpfr-4.1.0.tar.xz
	mv -v mpfr-4.1.0 mpfr
	tar -xf ../gmp-6.2.1.tar.xz
	mv -v gmp-6.2.1 gmp
	tar -xf ../mpc-1.2.1.tar.gz
	mv -v mpc-1.2.1 mpc
	case $(uname -m) in
		x86_64)
			sed -e '/m64=/s/lib64/lib/' \
				-i.orig gcc/config/i386/t-linux64
		;;
	esac
	mkdir -v build
	pushd build
		mkdir -pv $LFS_TGT/libgcc
		ln -s ../../../libgcc/gthr-posix.h \
			$LFS_TGT/libgcc/gthr-default.h
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
popd
rm -rf gcc-11.2.0

echo "Fin !"
