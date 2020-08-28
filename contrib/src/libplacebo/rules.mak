# libplacebo

PLACEBO_HASH := 5c6ad8508eef3e6f3d2e4a5c7cc96e164f5ef404
PLACEBO_BRANCH := master
PLACEBO_GITURL := https://code.videolan.org/videolan/libplacebo.git
PLACEBO_BASENAME := $(subst .,_,$(subst \,_,$(subst /,_,$(PLACEBO_HASH))))

DEPS_libplacebo = glslang

ifndef HAVE_WINSTORE
PKGS += libplacebo
endif
ifeq ($(call need_pkg,"libplacebo"),)
PKGS_FOUND += libplacebo
endif

ifdef HAVE_WIN32
DEPS_libplacebo += pthreads $(DEPS_pthreads)
endif

PLACEBOCONF := -Dglslang=enabled \
	-Dshaderc=disabled

$(TARBALLS)/libplacebo-$(PLACEBO_BASENAME).tar.xz:
	$(call download_git,$(PLACEBO_GITURL),$(PLACEBO_BRANCH),$(PLACEBO_HASH))

.sum-libplacebo: $(TARBALLS)/libplacebo-$(PLACEBO_BASENAME).tar.xz
	$(call check_githash,$(PLACEBO_HASH))
	touch $@

libplacebo: libplacebo-$(PLACEBO_BASENAME).tar.xz .sum-libplacebo
	$(UNPACK)
	$(MOVE)

.libplacebo: libplacebo crossfile.meson
	cd $< && rm -rf ./build
	cd $< && $(HOSTVARS_MESON) $(MESON) $(PLACEBOCONF) build
	cd $< && cd build && ninja install
# Work-around messon issue https://github.com/mesonbuild/meson/issues/4091
	sed -i.orig -e 's/Libs: \(.*\) -L$${libdir} -lplacebo/Libs: -L$${libdir} -lplacebo \1/g' $(PREFIX)/lib/pkgconfig/libplacebo.pc
# Work-around for full paths to static libraries, which libtool does not like
# See https://github.com/mesonbuild/meson/issues/5479
	(cd $(UNPACK_DIR) && $(SRC_BUILT)/pkg-rewrite-absolute.py -i "$(PREFIX)/lib/pkgconfig/libplacebo.pc")
	touch $@
