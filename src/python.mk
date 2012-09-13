# This file is part of MXE.
# See index.html for further information.

PKG             := python
$(PKG)_IGNORE   :=
$(PKG)_CHECKSUM := 842c4e2aff3f016feea3c6e992c7fa96e49c9aa0
$(PKG)_SUBDIR   := Python-$($(PKG)_VERSION)
$(PKG)_FILE     := Python-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := http://www.python.org/ftp/python/2.7.3/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

# configure parameters from # http://mdqinc.com/blog/2011/10/cross-compiling-python-for-windows-with-mingw32/
#
# export ARCH="win32"
# export CFLAGS=""
# export CXXFLAGS=""
# export CC="i586-mingw32msvc-gcc"
# export CXX="i586-mingw32msvc-g++"
# export AR="i586-mingw32msvc-ar"
# export RANLIB="i586-mingw32msvc-ranlib"
# export STRIP="i586-mingw32msvc-strip --strip-unneeded"
# export LD="i586-mingw32msvc-ld"
# export AS="i586-mingw32msvc-as"
# export NM="i586-mingw32msvc-nm"
# export DLLTOOL="i586-mingw32msvc-dlltool"
# export OBJDUMP="i586-mingw32msvc-objdump"
# export RESCOMP="i586-mingw32msvc-windres"
# export MAKE="make -k -j4 HOSTPYTHON=[PATH TO HOST PYTHON] HOSTPGEN=[PATH TO HOST PGEN]  CROSS_COMPILE=mingw32msvc CROSS_COMPILE_TARGET=yes"
# export EXTRALIBS="-lstdc++ -lgcc -lodbc32 -lwsock32 -lwinspool -lwinmm -lshell32 -lcomctl32 -lctl3d32 -lodbc32 -ladvapi32 -lopengl32 -lglu32 -lole32 -loleaut32 -luuid"
#
# ./configure LDFLAGS="-Wl,--no-export-dynamic -static-libgcc -static $EXTRALIBS" CFLAGS="-DMS_WIN32 -DMS_WINDOWS -DHAVE_USABLE_WCHAR_T" CPPFLAGS="-static" LINKFORSHARED=" " LIBOBJS="import_nt.o dl_nt.o getpathp.o" THREADOBJ="Python/thread.o" DYNLOADFILE="dynload_win.o" --disable-shared HOSTPYTHON=[PATH TO HOST PYTHON] HOSTPGEN=[PATH TO HOST PGEN] --host=i586-mingw32msvc --build=i686-pc-linux-gnu  --prefix="[WHERE YOU WANT TO PUT THE GENERATED PYTHON STUFF]"
#
define $(PKG)_BUILD
    cd '$(1)' && touch Include/graminit.h && touch Python/graminit.c && echo "" > Parser/pgen.stamp
    # revert this piece of the patch (bad word ...)
    perl -pi -e 's/^@INITSYS@/## @INITSYS@/' $(1)/Modules/Setup.config.in
    # define cite.config for the current arch
    echo -ne 'ac_cv_file__dev_ptmx=no \nac_cv_file__dev_ptc=no \nac_cv_have_long_long_format=yes \nac_cv_have_sendfile=no\n' > $(1)/$(TARGET).config.site
    # don't care for fruits now:
    # if [ $HOST = i686-apple-darwin11 ] ; then           
    #    echo "ac_osx_32bit=yes"                >> $(CFG_SITE)
    # elif [ $HOST = x86_64-apple-darwin11 ] ; then
    #    echo "ac_osx_32bit=no"                 >> $(CFG_SITE)
    # fi
    # as per comment at http://mdqinc.com/blog/2011/10/cross-compiling-python-for-windows-with-mingw32/
    cd '$(1)/Include' ; ln -s ../PC/errmap.h .
    #
    #
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --prefix='$(PREFIX)/$(TARGET)' \
        PKG_CONFIG='$(PREFIX)/bin/$(TARGET)-pkg-config' \
        CC='$(TARGET)-gcc' \
        CXX='$(TARGET)-g++' \
        AR='$(TARGET)-ar' \
        RANLIB='$(TARGET)-ranlib' \
        STRIP='$(TARGET)-strip --strip-unneeded' \
        LD='$(TARGET)-ld' \
        AS='$(TARGET)-as' \
        NM='$(TARGET)-nm' \
        DLLTOOL='$(TARGET)-dlltool' \
        OBJDUMP='$(TARGET)-objdump' \
        RESCOMP='$(TARGET)-windres' \
        CONFIG_SITE=$(1)/$(TARGET).config.site
    $(MAKE) -C '$(1)' -j '$(JOBS)' \
        INSTALL_TOP='$(PREFIX)/$(TARGET)'
endef
