# libgpg-error
# ftp://ftp.gnupg.org/gcrypt/libgpg-error/

PKG            := libgpg_error
$(PKG)_VERSION := 1.6
$(PKG)_SUBDIR  := libgpg-error-$($(PKG)_VERSION)
$(PKG)_FILE    := libgpg-error-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL     := ftp://ftp.gnupg.org/gcrypt/libgpg-error/$($(PKG)_FILE)
$(PKG)_DEPS    := gcc

define $(PKG)_UPDATE
    wget -q -O- 'ftp://ftp.gnupg.org/gcrypt/libgpg-error/' | \
    $(SED) -n 's,.*libgpg-error-\([0-9][^>]*\)\.tar.*,\1,p' | \
    tail -1
endef

define $(PKG)_BUILD
    # wine confuses the cross-compiling detection, so set it explicitly
    $(SED) 's,cross_compiling=no,cross_compiling=yes,' -i '$(1)/configure'
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)/$(TARGET)'
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef