#!/usr/bin/env sh

set -e

if [ "x$1" = "x" ]; then
	echo "$0 you must pass Ruby version"
	exit 1
fi

export DEBEMAIL="wojciech@koszek.com"
export DEBFULLNAME="Wojciech Adam Koszek"

V=2.4.0
V_=`echo $V | sed 's{\.{_{g'`
V_FILENAME=v${V_}.tar.gz
V_UNZIPPED=ruby-${V_}

echo "# V $V V_ $V_ V_FILENAME $V_FILENAME V_UNZIPPED $V_UNZIPPED"

if [ ! -f "${V_FILENAME}" ]; then
	echo "# ${V_FILENAME} not found. Will fetch it"
	wget https://github.com/ruby/ruby/archive/${V_FILENAME}
else
	echo "# ${V_FILENAME} found. Will use it"
fi

echo "# Will unzip the original release tarball ${V_FILENAME}"
tar xzf $V_FILENAME

echo "# Will autoconf and configure the package now"
(
	cd ${V_UNZIPPED}
#	make -f common.mk BASERUBY=ruby MAKEDIRS='mkdir -p' srcdir=.  update-config_files
	autoconf
	./configure -C --with-gcc=$CC
	#./configure -C --disable-install-doc --with-gcc=$CC $CONFIG_FLAG
)

echo "# Will take the directory from autoconf and build tarball with Makefile"
tar czf ${V_UNZIPPED}.tar.gz ${V_UNZIPPED}

# The bzr will ask something like this
#	Type of package: (single, indep, library, python)
#	[s/i/l/p]?
# and I send it "s". It works, but is unhappy at the end (Inappropriate ioctl
# for a device), returns non-zero, so I counter-smack it with "true" so that
# set -e of this shell script doesn't terminate. Alternative would be to use
# `expect`, but it requires 178MB of packages on Ubuntu.
echo "s" | bzr dh-make ruby ${V} ${V_UNZIPPED} || true

echo "# Remove ex/EX files and copy templates over"
ls -ld ruby/debian/*
rm -rf ruby/debian/*ex* ruby/debian/*EX*
cp debian/* ruby/debian/

echo "# Will build a package now"
(
	cd ruby
	bzr add debian/source/format
	bzr commit -m "Initial commit of Debian packaging."
	cd debian
	bzr builddeb -- -us -uc
)
