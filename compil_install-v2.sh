echo "Binutils"
tar -xf binutils-2.35.tar.xz
cd binutils-2.35
mkdir -p build && cd build
../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT -disable-nls --disable-werror
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make install
read -p "Press enter to continue..."
cd $LFS/sources
rm -rf binutils-2.35

echo "gcc"
tar -xf gcc-10.2.0.tar.xz
cd gcc-10.2.0
tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.0.tar.xz
mv -v gmp-6.2.0 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
mkdir -p build && cd build
../configure --target=$LFS_TGT --prefix=$LFS/tools --with-glibc-version=2.11 --with-sysroot=$LFS --with-newlib --without-headers --enable-initfini-array --disable-nls --disable-shared --disable-multilib --disable-decimal-float --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make install
read -p "Press enter to continue..."
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
cd $LFS/sources

echo "mrproper"
tar -xf linux-5.8.3.tar.xz
cd linux-5.8.3
make mrproper
read -p "Press enter to continue..."
make headers
read -p "Press enter to continue..."
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr
cd $LFS/sources

echo "glibc"
tar -xf glibc-2.32.tar.xz
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
read -p "Press enter to continue..."
ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
read -p "Press enter to continue..."
cd glibc-2.32
patch -Np1 -i ../glibc-2.32-fhs-1.patch
read -p "Press enter to continue..."
mkdir -p build && cd build
../configure --prefix=/usr --host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=3.2 --with-headers=$LFS/usr/include libc_cv_slibdir=/lib
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders
read -p "Press enter to continue..."
cd $LFS/sources

tar -xf gcc-10.2.0.tar.xz
cd gcc-10.2.0
mkdir -p build && cd build
../libstdc++-v3/configure --host=$LFS_TGT --build=$(../config.guess) --prefix=/usr --disable-multilib --disable-nls --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "=================== 6 ======================="

echo "m4"
tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "ncurses"
tar -xf ncurses-6.2.tar.gz
cd ncurses-6.2
sed -i s/mawk// configure
mkdir build
pushd build
	../configure
	make -C include
	read -p "Press enter to continue..."
	make -C progs tic
	read -p "Press enter to continue..."
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) --mandir=/usr/share/man --with-manpage-format=normal --with-shared --without-debug --without-ada --without-normal --enable-widec
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
read -p "Press enter to continue..."
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so
cd $LFS/sources

echo "bash"
tar -xf bash-5.0.tar.gz
cd bash-5.0
./configure --prefix=/usr --build=$(support/config.guess) --host=$LFS_TGT --without-bash-malloc
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
mv $LFS/usr/bin/bash $LFS/bin/bash
ln -sv bash $LFS/bin/sh
cd $LFS/sources

echo "coreutils" # 59
tar -xf coreutils-8.32.tar.xz
cd coreutils-8.32
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin
mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin
mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin
mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8
cd $LFS/sources

echo "diffutils"
tar -xf diffutils-3.7.tar.xz
cd diffutils-3.7
./configure --prefix=/usr --host=$LFS_TGT
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "file"
tar -xf file-5.39.tar.gz
cd file-5.39
./configure --prefix=/usr --host=$LFS_TGT
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "findutils"
tar -xf findutils-4.7.0.tar.xz
cd findutils-4.7.0
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
mv -v $LFS/usr/bin/find $LFS/bin
sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
cd $LFS/sources

echo "gawk"
tar -xf gawk-5.1.0.tar.xz
cd gawk-5.1.0
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "grep"
tar -xf grep-3.4.tar.xz
cd grep-3.4
./configure --prefix=/usr --host=$LFS_TGT --bindir=/bin
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "gzip"
tar -xf gzip-1.10.tar.xz
cd gzip-1.10
./configure --prefix=/usr --host=$LFS_TGT
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
mv -v $LFS/usr/bin/gzip $LFS/bin
cd $LFS/sources

echo "make"
tar -xf make-4.3.tar.gz
cd make-4.3
./configure --prefix=/usr --without-guile --host=$LFS_TGT --build=$(build-aux/config.guess)
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "patch"
tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr  --host=$LFS_TGT --build=$(build-aux/config.guess)
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "sed"
tar -xf sed-4.8.tar.xz
cd sed-4.8
./configure --prefix=/usr --host=$LFS_TGT --bindir=/bin
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "tar"
tar -xf tar-1.32.tar.xz
cd tar-1.32
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --bindir=/bin
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "xz"
tar -xf xz-5.2.5.tar.xz
cd xz-5.2.5
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.2.5
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin
mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib
ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so
cd $LFS/sources

echo "binutils"
tar -xf binutils-2.35.tar.xz
cd binutils-2.35
mkdir -p build && cd build
../configure --prefix=/usr --build=$(../config.guess) --host=$LFS_TGT --disable-nls --enable-shared --disable-werror --enable-64-bit-bfd
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
cd $LFS/sources

echo "gcc - 2"
rm -rf gcc-10.2.0
tar -xf gcc-10.2.0.tar.xz
cd gcc-10.2.0
tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.0.tar.xz
mv -v gmp-6.2.0 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
mkdir -v build
cd build
mkdir -pv $LFS_TGT/libgcc
ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
../configure --build=$(../config.guess) --host=$LFS_TGT --prefix=/usr CC_FOR_TARGET=$LFS_TGT-gcc --with-build-sysroot=$LFS --enable-initfini-array --disable-nls --disable-multilib --disable-decimal-float --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
read -p "Press enter to continue..."
make
read -p "Press enter to continue..."
make DESTDIR=$LFS install
read -p "Press enter to continue..."
ln -sv gcc $LFS/usr/bin/cc
cd $LFS/sources




