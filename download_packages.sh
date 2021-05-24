#export wg="wget --input-file=wget-list --continue --directory-prefix=$LFS/sources"
export wg="wget"
export myMd=verifmd5

verifmd5() {
	COUCOU=""
	IFS='//' read -ra my_array <<< "$1"
	for i in "${my_array[@]}"; do
		COUCOU=$i
	done

	if [ ! -f $COUCOU ]; then
		$wg "$1" 2>> my-log
		if [ "$2" == "$(md5sum < $COUCOU | sed 's/  -//g')" ]; then
			echo "Downloaded succesfully: $COUCOU"
		else
			echo "Error md5 to $COUCOU"
			exit 1
		fi
	else
		echo "File already downloaded: $COUCOU"
	fi
}

verifmd5 "http://download.savannah.gnu.org/releases/acl/acl-2.2.53.tar.gz" "007aabf1dbb550bcddde52a244cd1070"

verifmd5 "http://download.savannah.gnu.org/releases/attr/attr-2.4.48.tar.gz" "bc1e5cb5c96d99b24886f1f527d3bb3d"

verifmd5 "http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.xz" "50f97f4159805e374639a73e2636f22e"

verifmd5 "http://ftp.gnu.org/gnu/automake/automake-1.16.2.tar.xz" "6cb234c86f3f984df29ce758e6d0d1d7"

verifmd5 "http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz" "2b44b47b905be16f45709648f671820b"

verifmd5 "https://github.com/gavinhoward/bc/releases/download/3.1.5/bc-3.1.5.tar.xz" "bd6a6693f68c2ac5963127f82507716f"

verifmd5 "http://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz" "fc8d55e2f6096de8ff8171173b6f5087"

verifmd5 "http://ftp.gnu.org/gnu/bison/bison-3.7.1.tar.xz" "e7c8c321351ebdf70f5f0825f3faaee2"

verifmd5 "https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz" "67e051268d0c475ea773822f7500d0e5"

verifmd5 "https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz" "50fcafcecde5a380415b12e9c574e0b2"

verifmd5 "http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz" "022042695b7d5bcf1a93559a9735e668"

verifmd5 "https://dbus.freedesktop.org/releases/dbus/dbus-1.12.20.tar.gz" "dfe8a71f412e0b53be26ed4fbfdc91c4"

verifmd5 "http://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.2.tar.gz" "e1b07516533f351b3aba3423fafeffd6"

verifmd5 "http://ftp.gnu.org/gnu/diffutils/diffutils-3.7.tar.xz" "4824adc0e95dbbf11dfbdfaad6a1e461"

verifmd5 "https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.45.6/e2fsprogs-1.45.6.tar.gz" "cccfb706d162514e4f9dbfbc9e5d65ee"

verifmd5 "https://sourceware.org/ftp/elfutils/0.180/elfutils-0.180.tar.bz2" "23feddb1b3859b03ffdbaf53ba6bd09b"

#verifmd5 "https://dev.gentoo.org/~blueness/eudev/eudev-3.2.9.tar.gz" "dedfb1964f6098fe9320de827957331f"

verifmd5 "https://prdownloads.sourceforge.net/expat/expat-2.2.9.tar.xz" "d2384fa607223447e713e1b9bd272376"

verifmd5 "https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz" "00fce8de158422f5ccd2666512329bd2"

verifmd5 "ftp://ftp.astron.com/pub/file/file-5.39.tar.gz" "1c450306053622803a25647d88f80f25"

verifmd5 "http://ftp.gnu.org/gnu/findutils/findutils-4.7.0.tar.xz" "731356dec4b1109b812fecfddfead6b2"

verifmd5 "https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz" "2882e3179748cc9f9c23ec593d6adc8d"

verifmd5 "http://ftp.gnu.org/gnu/gawk/gawk-5.1.0.tar.xz" "8470c34eeecc41c1aa0c5d89e630df50"

verifmd5 "http://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz" "e9fd9b1789155ad09bcf3ae747596b50"

verifmd5 "http://ftp.gnu.org/gnu/gdbm/gdbm-1.18.1.tar.gz" "988dc82182121c7570e0cb8b4fcd5415"

verifmd5 "http://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.xz" "40996bbaf7d1356d3c22e33a8b255b31"

verifmd5 "http://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.xz" "720c7992861c57cf97d66a2f36d8d1fa"

verifmd5 "http://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz" "a325e3f09e6d91e62101e59f9bda3ec1"

verifmd5 "http://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz" "9e251c0a618ad0824b51117d5d9db87e"

verifmd5 "http://ftp.gnu.org/gnu/grep/grep-3.4.tar.xz" "111b117d22d6a7d049d6ae7505e9c4d2"

verifmd5 "http://ftp.gnu.org/gnu/groff/groff-1.22.4.tar.gz" "08fb04335e2f5e73f23ea4c3adbf0c5f"

verifmd5 "https://ftp.gnu.org/gnu/grub/grub-2.04.tar.xz" "5aaca6713b47ca2456d8324a58755ac7"

verifmd5 "http://ftp.gnu.org/gnu/gzip/gzip-1.10.tar.xz" "691b1221694c3394f1c537df4eee39d3"

verifmd5 "https://github.com/Mic92/iana-etc/releases/download/20200821/iana-etc-20200821.tar.gz" "ff19c45f5ac800f5d77c680d9b757fbc"

verifmd5 "http://ftp.gnu.org/gnu/inetutils/inetutils-1.9.4.tar.xz" "87fef1fa3f603aef11c41dcc097af75e"

verifmd5 "https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz" "12e517cac2b57a0121cda351570f1e63"

verifmd5 "https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-5.8.0.tar.xz" "e2016acc07d91b2508916c459a8435af"

verifmd5 "https://www.kernel.org/pub/linux/utils/kbd/kbd-2.3.0.tar.xz" "ac7ec9cedad48f4c279251cddc72008a"

verifmd5 "https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-27.tar.xz" "3973a74786670d3062d89a827e266581"

verifmd5 "http://www.greenwoodsoftware.com/less/less-551.tar.gz" "4ad4408b06d7a6626a055cb453f36819"

#verifmd5 "http://www.linuxfromscratch.org/lfs/downloads/10.0/lfs-bootscripts-20200818.tar.xz" "ef4abcaeddc1496f7a94b72af99e243a"

verifmd5 "https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.42.tar.xz" "f22cd619e04ae7b88a6a0c109b9523eb"

verifmd5 "ftp://sourceware.org/pub/libffi/libffi-3.3.tar.gz" "6313289e32f1d38a9df4770b014a2ca7"

verifmd5 "http://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.3.tar.gz" "dad443d0911cf9f0f1bd90a334bc9004"

verifmd5 "http://ftp.gnu.org/gnu/libtool/libtool-2.4.6.tar.xz" "1bfb9b923f2c1339b4d2ce1807064aa5"

verifmd5 "https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.8.3.tar.xz" "2656fe1a0942856c8740468d175e39b6"

verifmd5 "http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz" "730bb15d96fffe47e148d1e09235af82"

verifmd5 "http://ftp.gnu.org/gnu/make/make-4.3.tar.gz" "fc7a67ea86ace13195b0bce683fd4469"

verifmd5 "http://download.savannah.gnu.org/releases/man-db/man-db-2.9.3.tar.xz" "4c8721faa54a4c950c640e5e5c713fb0"

verifmd5 "https://www.kernel.org/pub/linux/docs/man-pages/man-pages-5.08.tar.xz" "ee4161cbf5ba59be7419937e063252d9"

verifmd5 "https://github.com/mesonbuild/meson/releases/download/0.55.0/meson-0.55.0.tar.gz" "9dd395356f7ec6ef40e2449fc9db3771"

verifmd5 "https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz" "4125404e41e482ec68282a2e687f6c73"

verifmd5 "http://www.mpfr.org/mpfr-4.1.0/mpfr-4.1.0.tar.xz" "bdd3d5efba9c17da8d83a35ec552baef"

verifmd5 "http://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz" "e812da327b1c2214ac1aed440ea3ae8d"

verifmd5 "https://github.com/ninja-build/ninja/archive/v1.10.0/ninja-1.10.0.tar.gz" "cf1d964113a171da42a8940e7607e71a"

verifmd5 "https://www.openssl.org/source/openssl-1.1.1g.tar.gz" "76766e98997660138cdaf13a187bd234"

verifmd5 "http://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz" "78ad9937e4caadcba1526ef1853730d5"

verifmd5 "https://www.cpan.org/src/5.0/perl-5.32.0.tar.xz" "3812cd9a096a72cb27767c7e2e40441c"

verifmd5 "https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz" "f6e931e319531b736fadc017f470e68a"

verifmd5 "https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-3.3.16.tar.xz" "e8dc8455e573bdc40b8381d572bbb89b"

verifmd5 "https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.3.tar.xz" "573bf80e6b0de86e7f307e310098cf86"

verifmd5 "https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tar.xz" "35b5a3d0254c1c59be9736373d429db7"

verifmd5 "https://www.python.org/ftp/python/doc/3.8.5/python-3.8.5-docs-html.tar.bz2" "2e0a549db8bef61733c37322368c815d"

verifmd5 "http://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz" "7e6c1f16aee3244a69aba6e438295ca3"

verifmd5 "http://ftp.gnu.org/gnu/sed/sed-4.8.tar.xz" "6d906edfdb3202304059233f51f9a71d"

verifmd5 "https://github.com/shadow-maint/shadow/releases/download/4.8.1/shadow-4.8.1.tar.xz" "4b05eff8a427cf50e615bda324b5bc45"

verifmd5 "https://github.com/systemd/systemd/archive/v246/systemd-246.tar.gz" "a3e9efa72d0309dd26513a221cdff31b"

verifmd5 "http://anduin.linuxfromscratch.org/LFS/systemd-man-pages-246.tar.xz" "819cc8ccffe51cb1863846fcb59a784a"

#verifmd5 "http://www.infodrom.org/projects/sysklogd/download/sysklogd-1.5.1.tar.gz" "c70599ab0d037fde724f7210c2c8d7f8"

#verifmd5 "http://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.97.tar.xz" "e11bc4b3eac6e6ddee7f8306230749a9"

verifmd5 "http://ftp.gnu.org/gnu/tar/tar-1.32.tar.xz" "83e38700a80a26e30b2df054e69956e5"

verifmd5 "https://downloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz" "97c55573f8520bcab74e21bfd8d0aadc"

verifmd5 "https://downloads.sourceforge.net/tcl/tcl8.6.10-html.tar.gz" "a012711241ba3a5bd4a04e833001d489"

verifmd5 "http://ftp.gnu.org/gnu/texinfo/texinfo-6.7.tar.xz" "d4c5d8cc84438c5993ec5163a59522a6"

verifmd5 "https://www.iana.org/time-zones/repository/releases/tzdata2020a.tar.gz" "96a985bb8eeab535fb8aa2132296763a"

#verifmd5 "http://anduin.linuxfromscratch.org/LFS/udev-lfs-20171102.tar.xz" "27cd82f9a61422e186b9d6759ddf1634"

verifmd5 "https://www.kernel.org/pub/linux/utils/util-linux/v2.36/util-linux-2.36.tar.xz" "fe7c0f7e439f08970e462c9d44599903"

verifmd5 "http://anduin.linuxfromscratch.org/LFS/vim-8.2.1361.tar.gz" "e07b0c1e71aa059cdfddc7c93c00c62a"

verifmd5 "https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.46.tar.gz" "80bb18a8e6240fcf7ec2f7b57601c170"

verifmd5 "https://tukaani.org/xz/xz-5.2.5.tar.xz" "aa1621ec7013a19abab52a8aff04fe5b"

verifmd5 "https://zlib.net/zlib-1.2.11.tar.xz" "85adef240c5f370b308da8c938951a68"

verifmd5 "https://github.com/facebook/zstd/releases/download/v1.4.5/zstd-1.4.5.tar.gz" "dd0b53631303b8f972dafa6fd34beb0c"

verifmd5 "http://www.linuxfromscratch.org/patches/lfs/10.0/bash-5.0-upstream_fixes-1.patch" "c1545da2ad7d78574b52c465ec077ed9"

verifmd5 "http://www.linuxfromscratch.org/patches/lfs/10.0/bzip2-1.0.8-install_docs-1.patch" "6a5ac7e89b791aae556de0f745916f7f"

verifmd5 "http://www.linuxfromscratch.org/patches/lfs/10.0/coreutils-8.32-i18n-1.patch" "cd8ebed2a67fff2e231026df91af6776"

verifmd5 "http://www.linuxfromscratch.org/patches/lfs/10.0/glibc-2.32-fhs-1.patch" "9a5997c3452909b1769918c759eff8a2"

verifmd5 "http://www.linuxfromscratch.org/patches/lfs/10.0/kbd-2.3.0-backspace-1.patch" "f75cca16a38da6caa7d52151f7136895"

