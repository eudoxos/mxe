# smpeg
# http://icculus.org/smpeg/
# http://packages.debian.org/unstable/source/smpeg

PKG            := smpeg
$(PKG)_VERSION := 0.4.5+cvs20030824
$(PKG)_SUBDIR  := smpeg-$($(PKG)_VERSION).orig
$(PKG)_FILE    := smpeg_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_URL     := http://ftp.debian.org/debian/pool/main/s/smpeg/$($(PKG)_FILE)
$(PKG)_DEPS    := gcc sdl

define $(PKG)_UPDATE
    wget -q -O- 'http://packages.debian.org/unstable/source/smpeg' | \
    $(SED) -n 's,.*smpeg_\([0-9][^>]*\)\.orig\.tar.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(1)' && ./configure \
        NM='$(TARGET)-nm' \
        --host='$(TARGET)' \
        --disable-shared \
        --disable-debug \
        --prefix='$(PREFIX)/$(TARGET)' \
        --with-sdl-prefix='$(PREFIX)/$(TARGET)' \
        --disable-sdltest \
        --disable-gtk-player \
        --disable-opengl-player \
        CFLAGS='-ffriend-injection'
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef