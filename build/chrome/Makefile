CC       = pnacl-clang
CXX      = pnacl-clang++
AR       = pnacl-ar
RANLIB   = pnacl-ranlib
FINALIZE = pnacl-finalize

CACKEY_LIBS = -Llib -lcackey -lz
PCSC_LIBS   = -Llib -lpcsc -L${NACL_SDK_ROOT}/lib/pnacl/Release -lppapi -lppapi_cpp
LIBS        = $(CACKEY_LIBS) $(PCSC_LIBS)
CFLAGS      = -Wall -I${NACL_SDK_ROOT}/include -I../../pkcs11 -Iinclude
CXXFLAGS    = $(CFLAGS) -std=gnu++11

CACKEY_DEBUG = 0
ifeq (1,$(CACKEY_DEBUG))
CACKEY_LIBNAME     = libcackey_g
CACKEY_EXECUTABLES = cackey.pexe cackey.bc
CFLAGS             += -g3 -ggdb3
CXXFLAGS           += -g3 -ggdb3
LDFLAGS            += -g3 -ggdb3
else
CACKEY_LIBNAME     = libcackey
CACKEY_EXECUTABLES = cackey.pexe
endif

PATH += :${NACL_SDK_ROOT}/toolchain/linux_pnacl/bin
export PATH

ifeq (,${NACL_SDK_ROOT})
$(error "Please set NACL_SDK_ROOT")
endif
export NACL_SDK_ROOT

all: cackey.zip

cackey.zip: $(CACKEY_EXECUTABLES) cackey.nmf manifest.json cackey.js ssh-agent.js google-pcsc.js pin.html pin.js pin-icon.png icon.png ui.html ui.js jsrsasign.js
	rm -f cackey.zip
	zip cackey.zip.new $^
	mv cackey.zip.new cackey.zip

cackey.bc: cackey-chrome-pkcs11.o cackey-chrome-plugin.o lib/libcackey.a lib/libpcsc.a lib/libz.a
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o cackey.bc.new cackey-chrome-pkcs11.o cackey-chrome-plugin.o $(LIBS)
	mv cackey.bc.new cackey.bc

cackey.pexe: cackey.bc
	cp cackey.bc cackey.pexe.new
	$(FINALIZE) cackey.pexe.new
	mv cackey.pexe.new cackey.pexe

cackey.nmf: $(CACKEY_EXECUTABLES)
	${NACL_SDK_ROOT}/tools/create_nmf.py $(CACKEY_EXECUTABLES) > cackey.nmf.new
	mv cackey.nmf.new cackey.nmf

lib/libcackey.a: build-deps ../../cackey.c archive/smart-card-client-c-example-app-sources.zip
	mkdir -p lib
	rm -f lib/libcackey.a
	rm -rf workdir-*
	+./build-deps
	cd lib && ln -s ../workdir-*.inst/lib/$(CACKEY_LIBNAME).a libcackey.a
	touch lib/libcackey.a

lib/libpcsc.a: lib/libcackey.a
	mkdir -p lib
	rm -f lib/libpcsc.a
	cd lib && ln -s ../workdir-*.inst/lib/libpcsc.a .
	touch lib/libpcsc.a

lib/libz.a: lib/libcackey.a
	mkdir -p lib
	rm -f lib/libz.a
	cd lib && ln -s ../workdir-*.inst/lib/libz.a .
	touch lib/libz.a

google-pcsc.js: lib/libcackey.a
	rm -f google-pcsc.js google-pcsc.js.new
	if [ "$(CACKEY_DEBUG)" = '1' ]; then CACKEY_DEBUG_BOOL='true'; else CACKEY_DEBUG_BOOL='false'; fi; sed 's@goog.define(.goog\.DEBUG., .*);@goog.define('"'"'goog.DEBUG'"'"', '"$${CACKEY_DEBUG_BOOL}"');@' workdir-*.inst/js/libpcsc.js > google-pcsc.js.new
	mv google-pcsc.js.new google-pcsc.js

include/libpcsc.h: lib/libcackey.a
	mkdir -p include
	rm -f include/libpcsc.h.new include/libpcsc.h
	cd include && ln -s ../workdir-*.inst/include/libpcsc.h libpcsc.h.new
	touch include/libpcsc.h.new
	mv include/libpcsc.h.new include/libpcsc.h

manifest.json: manifest.json.in ../../configure.ac
	rm -f manifest.json.new
	sed 's/@PACKAGE_VERSION@/$(shell sed '/^AC_INIT/ {s@.*, @@;s@[^0-9\.].@@g;p};d' ../../configure.ac)/g' manifest.json.in > manifest.json.new
	mv manifest.json.new manifest.json

jsrsasign.js:
	wget --no-check-certificate -O jsrsasign.js.new 'https://raw.githubusercontent.com/kjur/jsrsasign/d282c71cee92000c4807bcbf2212fedf3f22bd84/jsrsasign-all-min.js'
	test "`openssl sha256 jsrsasign.js.new | sed 's@.*= *@@'`" = '108d6988362ac8a140cbeca45906518c7e64930f5e21813f21a8505a0d6b5edd'
	mv jsrsasign.js.new jsrsasign.js

test: cackey-chrome-pkcs11.c cackey-chrome-test.c ../../cackey.c Makefile
	gcc -g3 -ggdb3 -Wall -I. -I../../pkcs11 -I/opt/appfs/core.appfs.rkeene.org/zlib/platform/latest/include -I/opt/appfs/rkeene.org/pcsc-lite/platform/latest/include/PCSC -DHAVE_WINTYPES_H=1 -DHAVE_PCSCLITE_H=1 -DHAVE_WINSCARD_H=1 -DHAVE_STDINT_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDLIB_H=1 -DHAVE_UNISTD_H=1 -DHAVE_STRING_H=1 -DHAVE_PTHREAD_H=1 -DHAVE_LIMITS_H=1 -DHAVE_STDIO_H=1 -DHAVE_ZLIB_H -DHAVE_LIBZ -DCACKEY_DEBUG=1 -o test cackey-chrome-pkcs11.c cackey-chrome-test.c ../../cackey.c -L/opt/appfs/core.appfs.rkeene.org/zlib/platform/latest/lib -lz -L/opt/appfs/rkeene.org/pcsc-lite/platform/latest/lib -lpcsclite -L/opt/appfs/core.appfs.rkeene.org/glibc/platform/latest/lib -lc -lpthread -Wl,-R,/opt/appfs/core.appfs.rkeene.org/zlib/platform/latest/lib -Wl,-R,/opt/appfs/rkeene.org/pcsc-lite/platform/latest/lib -Wl,-R,/opt/appfs/core.appfs.rkeene.org/glibc/platform/latest/lib -Wl,-dynamic-linker,/opt/appfs/core.appfs.rkeene.org/glibc/platform/latest/lib/ld-linux-x86-64.so.2

cackey-chrome-pkcs11.o: cackey-chrome-pkcs11.c cackey-chrome.h
cackey-chrome-plugin.o: cackey-chrome-plugin.cc cackey-chrome.h include/libpcsc.h

clean:
	rm -f cackey-chrome-pkcs11.o cackey-chrome-plugin.o
	rm -f cackey.pexe cackey.bc
	rm -f cackey.zip cackey.nmf
	rm -f manifest.json manifest.json.new
	rm -f test

distclean: clean
	rm -f lib/libcackey.a lib/libpcsc.a lib/libz.a
	-rmdir lib
	rm -f include/libpcsc.h
	-rmdir include/PCSC
	-rmdir include
	rm -f google-pcsc.js
	rm -rf workdir-*
	rm -f jsrsasign.js jsrsasign.js.new

.PHONY: all clean distclean
