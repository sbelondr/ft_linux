#!/bin/bash


# 7.2
chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
	x86_64) chown -R root:root $LFS/lib64 ;;
esac

# 7.3
mkdir -pv $LFS/{dev,proc,sys,run}

mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3

mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
	mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi
chroot "$LFS" /usr/bin/env -i \
	HOME=/root \
	TERM="$TERM" \
	PS1='(lfs chroot) \u:\w\$ ' \
	PATH=/usr/bin:/usr/sbin \
	/bin/bash --login +h
mkdir -pv /{boot,home,mnt,opt,srv}

mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{include,src}
mkdir -pv /usr/local/{bin,lib,sbin}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}
ln -sfv /run /var/run
ln -sfv /run/lock /var/lock
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

ln -sv /proc/self/mounts /etc/mtab
cat > /etc/hosts << EOF
127.0.0.1 localhost $(hostname)
::1
localhost
EOF
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF

echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester
exec /bin/bash --login +h
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664 /var/log/lastlog
chmod -v 600 /var/log/btmp

# install package 7.7 >

echo "libstdc"
tar -xf gcc-11.2.0.tar.xz
pushd gcc-11.2.0
	ln -s gthr-posix.h libgcc/gthr-default.h
	mkdir -v build
	pushd build
		../libstdc++-v3/configure \
			CXXFLAGS="-g -O2 -D_GNU_SOURCE" \
			--prefix=/usr \
			--disable-multilib \
			--disable-nls \
			--host=$(uname -m)-lfs-linux-gnu \
			--disable-libstdcxx-pch
		make
		make install		
	popd
popd
rm -rf gcc-11.2.0

echo "gettext-0.21.tar.xz"
tar -xf gettext-0.21
pushd gettext-0.21
	./configure --disable-shared
	make
	cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
popd
rm -rf gettext-0.21


echo "bison-3.7.6.tar.xz"
tar -xf bison-3.7.6.tar.xz
pushd bison-3.7.6
	./configure --prefix=/usr \
		--docdir=/usr/share/doc/bison-3.7.6
	make
	make install
popd
rm -rf bison-3.7.6

echo "perl-5.34.0.tar.xz"
tar -xf perl-5.34.0.tar.xz
pushd perl-5.34.0
	sh Configure -des \
		-Dprefix=/usr \
		-Dvendorprefix=/usr \
		-Dprivlib=/usr/lib/perl5/5.34/core_perl \
		-Darchlib=/usr/lib/perl5/5.34/core_perl \
		-Dsitelib=/usr/lib/perl5/5.34/site_perl \
		-Dsitearch=/usr/lib/perl5/5.34/site_perl \
		-Dvendorlib=/usr/lib/perl5/5.34/vendor_perl \
		-Dvendorarch=/usr/lib/perl5/5.34/vendor_perl
	make
	make install
popd
rm -rf perl-5.34.0

echo "Python-3.9.6.tar.xz"
tar -xf Python-3.9.6.tar.xz
pushd Python-3.9.6
	./configure --prefix=/usr \
		--enable-shared \
		--without-ensurepip
	make
	make install
popd
rm -rf Python-3.9.6

echo "texinfo-6.8.tar.xz"
tar -xf texinfo-6.8.tar.xz
pushd texinfo-6.8
	sed -e 's/__attribute_nonnull__/__nonnull/' \
		-i gnulib/lib/malloc/dynarray-skeleton.c
	./configure --prefix=/usr
	make
	make install
popd
rm -rf texinfo-6.8

echo ""util-linux-2.37.2.tar.xz
tar -xf util-linux-2.37.2.tar.xz
pushd util-linux-2.37.2
	mkdir -pv /var/lib/hwclock
	./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
		--libdir=/usr/lib \
		--docdir=/usr/share/doc/util-linux-2.37.2 \
		--disable-chfn-chsh \
		--disable-login \
		--disable-nologin \
		--disable-su \
		--disable-setpriv \
		--disable-runuser \
		--disable-pylibmount \
		--disable-static \
		--without-python \
		runstatedir=/run
	make
	make install
popd
rm -rf util-linux-2.37.2

rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools

echo "go to 7.14.2 and follow instruction"
