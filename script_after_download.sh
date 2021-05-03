mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var}

case $(uname -m) in
	x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools

groupadd lfs

useradd -s /bin/bash -g lfs -m -k /dev/null lfs

passwd lfs

chown -v lfs $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
	x86_64) chown -v lfs $LFS/lib64 ;;
esac

chown -v lfs $LFS/sources
