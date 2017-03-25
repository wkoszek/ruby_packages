#!/usr/bin/env sh

set -e

export DEBEMAIL="wojciech@koszek.com"
export DEBFULLNAME="Wojciech Adam Koszek"

V=2.4.0
if [ "x$RUBY_PKG_VERSION" != "x" ]; then
  V=$RUBY_PKG_VERSION
fi
V_=`echo $V | sed 's{\.{_{g'`
V_PREFIXED=v${V_}
V_FILENAME=${V_PREFIXED}.tar.gz
V_UNZIPPED=ruby-${V_}
V_URL=https://github.com/ruby/ruby/archive/${V_FILENAME}

echo "# V $V V_ $V_ V_FILENAME $V_FILENAME V_UNZIPPED $V_UNZIPPED"

if [ ! -f "${V_FILENAME}" ]; then
	echo "# ${V_FILENAME} not found. Will fetch it"
	wget $V_URL
else
	echo "# ${V_FILENAME} found. Will use it"
fi

echo "# Will unzip the original release tarball ${V_FILENAME}"
tar xzf $V_FILENAME

echo "# Will autoconf and configure the package now"
(
	cd ${V_UNZIPPED}
	autoconf
	./configure -C --with-gcc=$CC
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

if [ "x$CI" != "x" ]; then
	. ~/.ssh/agent_env
	chmod 600 etc/deploy
	ssh-add etc/deploy
	TAG_NAME="${V_PREFIXED}_${TRAVIS_BUILD_ID}"
	git tag -a "$TAG_NAME" -m "Ruby ${V_} build on Travis job ${TRAVIS_BUILD_ID}"
	git remote add github git@github.com:wkoszek/ruby_packages.git
	git push --tags github
	./make-release.rb `/bin/ls -1 *.deb` $TAG_NAME $V_URL
fi
