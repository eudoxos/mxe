# Copyright (C) 2009  Volker Grabsch
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject
# to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# TDM-GCC
PKG             := gcc-tdm
$(PKG)_IGNORE   := 4.4.1-tdm-2
$(PKG)_VERSION  := 4.4.0-tdm-1
$(PKG)_CHECKSUM := ec1c81acf0581b4f1e2d5498ce9cd015b63e917b
$(PKG)_SUBDIR   := .
$(PKG)_FILE     := gcc-$($(PKG)_VERSION)-srcbase-2.zip
$(PKG)_WEBSITE  := http://www.tdragon.net/recentgcc/
$(PKG)_URL      := http://$(SOURCEFORGE_MIRROR)/project/tdm-gcc/Sources/TDM Sources/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     :=

define $(PKG)_UPDATE
    $(call SOURCEFORGE_FILES,http://sourceforge.net/projects/tdm-gcc/files/Sources/) | \
    $(SED) -n 's,.*gcc-\([0-9][^>]*\)-srcbase[-0-9]*\.zip.*,\1,p' | \
    tail -1
endef