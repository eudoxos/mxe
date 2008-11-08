# MinGW cross compiling environment
# see doc/README for further information

JOBS               := 4
TARGET             := i386-mingw32msvc
SOURCEFORGE_MIRROR := kent.dl.sourceforge.net

VERSION := 2.0
PREFIX  := $(PWD)/usr
PKG_DIR := $(PWD)/pkg
TMP_DIR  = $(PWD)/tmp-$(1)
PATH    := $(PREFIX)/bin:$(PATH)
SED     := $(shell gsed --version >/dev/null 2>&1 && echo g)sed

PKG_RULES := $(patsubst src/%.mk,%,$(wildcard src/*.mk))
include src/*.mk

CHECK_ARCHIVE = \
    $(if $(filter %.tar.gz, $(1)),tar tfz '$(1)' >/dev/null 2>&1, \
    $(if $(filter %.tar.bz2,$(1)),tar tfj '$(1)' >/dev/null 2>&1, \
    $(if $(filter %.zip,    $(1)),unzip -t '$(1)' >/dev/null 2>&1, \
    $(error Unknown archive format: $(1)))))

UNPACK_ARCHIVE = \
    $(if $(filter %.tar.gz, $(1)),tar xvzf '$(1)', \
    $(if $(filter %.tar.bz2,$(1)),tar xvjf '$(1)', \
    $(if $(filter %.zip,    $(1)),unzip '$(1)', \
    $(error Unknown archive format: $(1)))))

DOWNLOAD = \
    $(if $(2),wget -t 3 -c '$(1)' || wget -c '$(2)',wget -c '$(1)')

.PHONY: all
all: $(PKG_RULES)

define PKG_RULE
.PHONY: $(1)
$(1): $(PREFIX)/installed.$(1)
$(PREFIX)/installed.$(1): $(addprefix $(PREFIX)/installed.,$($(1)_DEPS))
	[ -z '$(PREFIX)' ] || mkdir -p '$(PREFIX)'
	[ -z '$(PKG_DIR)' ] || mkdir -p '$(PKG_DIR)'
	rm -rf   '$(2)'
	mkdir -p '$(2)'
	cd '$(PKG_DIR)' && ( \
	    $(call CHECK_ARCHIVE,$($(1)_FILE)) || \
	    $(call DOWNLOAD,$($(1)_URL),$($(1)_URL_2)) )
	cd '$(2)' && \
	    $(call UNPACK_ARCHIVE,$(PKG_DIR)/$($(1)_FILE))
	$$(call $(1)_BUILD,$(2)/$($(1)_SUBDIR))
	rm -rfv '$(2)'
	touch '$$@'
endef
$(foreach PKG,$(PKG_RULES),$(eval $(call PKG_RULE,$(PKG),$(call TMP_DIR,$(PKG)))))

.PHONY: strip
strip:
	rm -rf \
	    $(PREFIX)/include \
	    $(PREFIX)/info \
	    $(PREFIX)/lib/libiberty.a \
	    $(PREFIX)/man \
	    $(PREFIX)/$(TARGET)/doc \
	    $(PREFIX)/$(TARGET)/info \
	    $(PREFIX)/$(TARGET)/man \
	    $(PREFIX)/$(TARGET)/sbin \
	    $(PREFIX)/$(TARGET)/share
	-strip -s \
	    $(PREFIX)/bin/* \
	    $(PREFIX)/libexec/gcc/$(TARGET)/*/* \
	    $(PREFIX)/$(TARGET)/bin/*
	-$(TARGET)-strip -g \
	    $(PREFIX)/lib/gcc/$(TARGET)/*/*.a \
	    $(PREFIX)/lib/gcc/$(TARGET)/*/*.o \
	    $(PREFIX)/$(TARGET)/lib/*.a \
	    $(PREFIX)/$(TARGET)/lib/*.o

.PHONY: clean
clean:
	rm -rf $(call TMP_DIR,*) $(PREFIX)/*

.PHONY: update
define UPDATE
    $(if $(2), \
        $(info $(1): $(2)) \
        $(SED) 's/^\([^ ]*_VERSION *:=\).*/\1 $(2)/' -i src/$(1).mk, \
        $(error Unable to update version number: $(1)))

endef
update:
	$(foreach PKG,$(PKG_RULES),$(call UPDATE,$(PKG),$(shell $($(PKG)_UPDATE))))

.PHONY: dist
dist:
	rm -rf 'mingw_cross_env-$(VERSION)'
	mkdir  'mingw_cross_env-$(VERSION)'
	mkdir  'mingw_cross_env-$(VERSION)/doc'
	mkdir  'mingw_cross_env-$(VERSION)/src'
	hg log -v --style changelog >'mingw_cross_env-$(VERSION)/doc/ChangeLog'
	( \
	    $(SED) -n '1,/^List/ { s/^\(MinGW cross.*\)/\1  ($(VERSION))/; p }' doc/README && \
	    echo '================' && \
	    echo && \
	    ($(foreach PKG,$(PKG_RULES),echo '$(PKG)' '$($(PKG)_VERSION)';)) | \
	        awk '{ printf "    %-12s  %s\n", $$1, $$2 }' && \
	    echo && \
	    echo && \
	    $(SED) -n '/^Copyright/,$$ p' doc/README \
	) >'mingw_cross_env-$(VERSION)/doc/README'
	cp -p Makefile 'mingw_cross_env-$(VERSION)/'
	cp -p src/*.mk 'mingw_cross_env-$(VERSION)/src/'
	tar cvf - 'mingw_cross_env-$(VERSION)' | gzip -9 >'mingw_cross_env-$(VERSION).tar.gz'
	rm -rf 'mingw_cross_env-$(VERSION)'
