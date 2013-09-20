#!/bin/sh

# The purpose of this script is to document the process of 
# building the tools needed for OS161.
#
# Modified September 2012 and tested on Ubuntu 12 distribution by demke

# Recent Desktop Ubuntu installations do not include some utilities that
# are needed to build these tools.  You may need to install the gettext
# package if msgfmt is missing on your system (e.g. if "which msgfmt"
# finds nothing). Also, if you get complaints about missing termcap.
# In that case, try adding these packages:
# apt-get install gettext
# apt-get install libncurses5-dev

# If you are running os161 on CDF then you do not need to run this script.
# You do need to have /u/csc369h/fall/pub/tools/bin in your PATH variable.

check_exit () {
  if [ $1 -ne 0 ]
  then
    echo "build_all.sh is bailing."
    exit $1
  fi
}

INSTALL_DIR=/home/italo/Documents/csc369/os161/tools/

# this is for bmake
#OSTYPE=Darwin
OSTYPE=Linux

# You should really have this in your PATH 
# (set in ~/.bashrc, ~/.profile, or ~/.cshrc)
export PATH=$INSTALL_DIR/bin:$PATH

basedir=$PWD

##################################################################
# Unpack, configure, compile and install binutils. 
# binutils contains libraries needed by gcc and gdb

echo "unpacking binutils"
tar -xzf binutils-2.17+os161-2.0.1.tar.gz; check_exit $?
echo "Building binutils"
cd binutils-2.17+os161-2.0.1; check_exit $?

# The werror compile flag turns warnings into errors.  It is frustrating
# that gcc does not compile cleanly without warnings. The note to
# disable-werror prevents flagging warnings as errors.
./configure --nfp --disable-werror --target=mips-uoft-os161 --prefix=$INSTALL_DIR; check_exit $?

# The distribution fails to build because the required version of makeinfo
# is not installed.  The files don't need to be rebuilt, so we will just
# modify the timestamp.
find . -name '*.info' | xargs touch
make; check_exit $?
make install; check_exit $?
cd $basedir

##################################################################
# Unpack, configure, compile and install gcc cross compiler

echo "unpacking gcc"
tar -xzf gcc-4.1.2+os161-2.0.tar.gz; check_exit $?
echo "Building gcc"
cd gcc-4.1.2+os161-2.0 && check_exit $?
./configure --nfp --disable-shared --disable-threads --disable-libmudflap --disable-libssp --target=mips-uoft-os161 --prefix=$INSTALL_DIR; check_exit $?
find . -name '*.info' | xargs touch
make; check_exit $?
make install; check_exit $?
cd $basedir

##################################################################
# Unpack, configure, compile and install gdb
#
# Maybe a 64-bit issue, but in my Ubuntu 12.04 VM, gdb also generates a 
# warning during compile, so this is also configured with --disable-werror

echo "unpacking gdb"
tar -xzf gdb-6.6+os161-2.0.tar.gz; check_exit $?
echo "Building gdb"
cd gdb-6.6+os161-2.0; check_exit $?
./configure --disable-werror --target=mips-uoft-os161 --prefix=$INSTALL_DIR; check_exit $?
find . -name '*.info' | xargs touch
make; check_exit $?
make install; check_exit $?
cd $basedir


##################################################################
# Unpack, configure, compile and install bmake
# This is the berkeley make which works a little differently than gnu make

echo "unpacking bmake"
tar -xzf bmake-20101215.tar.gz; check_exit $?
# For some reason part of bmake has to be added to the bmake directory.
echo "adding mk to bmake directory"
cp mk-20100612.tar.gz bmake; check_exit $?
cd bmake; check_exit $?
tar -xzf mk-20100612.tar.gz; check_exit $?
cd $basedir
echo "Building bmake"
cd bmake; check_exit $?
./configure --prefix=$INSTALL_DIR; check_exit $?
./boot-strap --prefix=$INSTALL_DIR; check_exit $?
cp $OSTYPE/bmake $INSTALL_DIR/bin/bmake; check_exit $?
sh mk/install-mk $INSTALL_DIR/share/mk; check_exit $?

cd $basedir

##################################################################
# Unpack, configure, compile and install sys161

echo "unpacking sys161"
tar -xzf sys161-1.99.05.tar.gz; check_exit $?
echo "Building sys161"
cd sys161-1.99.05; check_exit $?
./configure --prefix=$INSTALL_DIR mipseb; check_exit $?
make; check_exit $?
make install; check_exit $?
cd $basedir


##################################################################
# Create shorter names for the tools

cd $INSTALL_DIR/bin
sh -c 'for i in mips-*; do ln -s $i os161-`echo $i | cut -d- -f4-`; done'

echo "Done"
