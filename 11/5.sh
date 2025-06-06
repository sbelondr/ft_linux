#!/bin/bash

tar -xf binutils-2.37.tar.xz
echo "Install binutils"
pushd binutils-2.37
	mkdir -v build
	pushd build
		../configure --prefix=$LFS/tools --with-sysroot=$LFS \
			--target=$LFS_TGT \
			--disable-nls \
			--disable-werror
		make
		make install -j1
	popd
popd
rm -rf binutils-2.37

echo "Install GCC pass 1"
tar-xf gcc-11.2.0.tar.xz
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
		../configure \
			--target=$LFS_TGT \
			--prefix=$LFS/tools \
			--with-glibc-version=2.11 \
			--with-sysroot=$LFS \
			--with-newlib \
			--without-headers \
			--enable-initfini-array \
			--disable-nls \
			--disable-shared \
			--disable-multilib \
			--disable-decimal-float \
			--disable-threads \
			--disable-libatomic \
			--disable-libgomp \
			--disable-libquadmath \
			--disable-libssp \
			--disable-libvtv \
			--disable-libstdcxx \
			--enable-languages=c,c++
		make
		make install
	popd
	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
		`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
popd
rm -rf gcc-11.2.0

echo "Install linux-5.1.3"
tar -xf linux-5.13.12.tar.xz
pushd linux-5.13.12
	make mrproper
	make headers
	find usr/include -name '.*' -delete
	rm usr/include/Makefile
	cp -rv usr/include $LFS/usr
popd
rm -rf linux-5.13.12

echo "Install glibc"
tar -xf glibc-2.34.tar.xz
pushd glibc-2.34
	case $(uname -m) in
		i?86) ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
		;;
		x86_64)
			ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
			ln -sfv ../lib/ld-linux-x86-64.so.2 \
				$LFS/lib64/ld-lsb-x86-64.so.3
		;;
	esac
	patch -Np1 -i ../glibc-2.34-fhs-1.patch
	mkdir -v build
	pushd build
		echo "rootsbindir=/usr/sbin" > configparms
		../configure \
			--prefix=/usr \
			--host=$LFS_TGT \
			--build=$(../scripts/config.guess) \
			--enable-kernel=3.2 \
			--with-headers=$LFS/usr/include \
			libc_cv_slibdir=/usr/lib
		make
		make DESTDIR=$LFS install
		sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
		$LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders
	popd
popd
rm -rf glibc-2.34

echo "Install Libstdc++"
tar -xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
	mkdir -v build
	pushd build
		../libstdc++-v3/configure \
			--host=$LFS_TGT \
			--build=$(../config.guess) \
			--prefix=/usr \
			--disable-multilib \
			--disable-nls \
			--disable-libstdcxx-pch \
			--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0
		make
		make DESTDIR=$LFS install
	popd
popd
rm -rf gcc-11.2.0
