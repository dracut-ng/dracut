
DRACUT_MAIN_VERSION ?= $(shell env GIT_CEILING_DIRECTORIES=$(CURDIR)/.. git describe --abbrev=0 --tags --always 2>/dev/null || :)
ifeq ($(DRACUT_MAIN_VERSION),)
DRACUT_MAIN_VERSION := $(shell sed -n 's/^DRACUT_VERSION="\(.*\)"$$/\1/p' dracut.sh)
endif
DRACUT_FULL_VERSION ?= $(shell env GIT_CEILING_DIRECTORIES=$(CURDIR)/.. git describe --tags --always 2>/dev/null || :)
ifeq ($(DRACUT_FULL_VERSION),)
DRACUT_FULL_VERSION := $(shell sed -n 's/^DRACUT_VERSION="\(.*\)"$$/\1/p' dracut.sh)
endif

HAVE_SHELLCHECK ?= $(shell command -v shellcheck >/dev/null 2>&1 && echo yes)
HAVE_SHFMT ?= $(shell command -v shfmt >/dev/null  2>&1 && echo yes)

-include Makefile.inc

prefix ?= /usr
libdir ?= ${prefix}/lib
datadir ?= ${prefix}/share
pkglibdir ?= ${libdir}/dracut
sysconfdir ?= ${prefix}/etc
bindir ?= ${prefix}/bin
mandir ?= ${prefix}/share/man
CFLAGS ?= -O2 -g -Wall -std=gnu99 -D_FILE_OFFSET_BITS=64 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2
bashcompletiondir ?= ${datadir}/bash-completion/completions
pkgconfigdatadir ?= $(datadir)/pkgconfig
ARCH ?= $(shell uname -m)

configs = \
	fips/10-fips.conf \
	generic/11-generic.conf \
	hostonly/10-hostonly.conf \
	ima/10-ima.conf \
	no-network/10-no-network.conf \
	rescue/10-rescue.conf \
	$(NULL)

test_configs = \
	test-makeroot/test-makeroot.conf \
	test-root/test-root.conf \
	test/test.conf \
	$(NULL)

man1pages = man/lsinitrd.1

man5pages = man/dracut.conf.5

man7pages = man/dracut.cmdline.7 \
            man/dracut.bootup.7 \
            man/dracut.modules.7

man8pages = man/dracut.8 \
            man/dracut-catimages.8 \
            modules.d/77dracut-systemd/dracut-cmdline.service.8 \
            modules.d/77dracut-systemd/dracut-mount.service.8 \
            modules.d/77dracut-systemd/dracut-shutdown.service.8 \
            modules.d/77dracut-systemd/dracut-pre-mount.service.8 \
            modules.d/77dracut-systemd/dracut-pre-pivot.service.8 \
            modules.d/77dracut-systemd/dracut-pre-trigger.service.8 \
            modules.d/77dracut-systemd/dracut-pre-udev.service.8 \
            modules.d/77initqueue/dracut-initqueue.service.8

manpages = $(man1pages) $(man5pages) $(man7pages) $(man8pages)

.PHONY: install clean distclean archive test all check AUTHORS CONTRIBUTORS doc

all: dracut.pc dracut-install src/skipcpio/skipcpio dracut-util

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(KMOD_CFLAGS) $(SYSTEMD_CFLAGS) $(if $(SYSTEMD_LIBS),-DHAVE_SYSTEMD) $< -o $@

DRACUT_INSTALL_OBJECTS = \
        src/install/dracut-install.o \
        src/install/hashmap.o\
        src/install/log.o \
        src/install/strv.o \
        src/install/util.o

# deps generated with gcc -MM
src/install/dracut-install.o: src/install/dracut-install.c src/install/log.h src/install/macro.h \
	src/install/hashmap.h src/install/util.h
src/install/hashmap.o: src/install/hashmap.c src/install/util.h src/install/macro.h src/install/log.h \
	src/install/hashmap.h
src/install/log.o: src/install/log.c src/install/log.h src/install/macro.h src/install/util.h
src/install/util.o: src/install/util.c src/install/util.h src/install/macro.h src/install/log.h
src/install/strv.o: src/install/strv.c src/install/strv.h src/install/util.h src/install/macro.h src/install/log.h

src/install/dracut-install: $(DRACUT_INSTALL_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(DRACUT_INSTALL_OBJECTS) $(LDLIBS) $(FTS_LIBS) $(KMOD_LIBS) $(SYSTEMD_LIBS)

dracut-install: src/install/dracut-install
	ln -fs $< $@

SKIPCPIO_OBJECTS = src/skipcpio/skipcpio.o
skipcpio/skipcpio.o: src/skipcpio/skipcpio.c
skipcpio/skipcpio: $(SKIPCPIO_OBJECTS)

UTIL_OBJECTS = src/util/util.o
util/util.o: src/util/util.c
util/util: $(UTIL_OBJECTS)

dracut-util: src/util/util
	cp -a $< $@

.PHONY: indent-c
indent-c:
	astyle -n --quiet --options=.astylerc $(wildcard *.[ch] */*.[ch] src/*/*.[ch])

.PHONY: indent
indent: indent-c
ifeq ($(HAVE_SHFMT),yes)
	shfmt --apply-ignore -w .
endif

src/dracut-cpio/target/release/dracut-cpio: src/dracut-cpio/src/main.rs
	cargo --offline build --release --manifest-path src/dracut-cpio/Cargo.toml

dracut-cpio: src/dracut-cpio/target/release/dracut-cpio
	ln -fs $< $@

ifeq ($(enable_dracut_cpio),yes)
all: dracut-cpio
endif

doc: $(manpages)

ifneq ($(enable_documentation),no)
all: doc
endif

ifeq ($(disable_asciidoctor),yes)
$(warning *** Building with asciidoc deprecated)
%: %.xml
	@rm -f -- "$@"
	xsltproc -o "$@" -nonet http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl $<

%.xml: %.adoc
	@rm -f -- "$@"
	asciidoc -f man/asciidoc.conf -a "version=$(DRACUT_FULL_VERSION)" -d manpage -b docbook -o "$@" $<
else
define ASCIIDOC_MANPAGE
	asciidoctor -a "version=$(DRACUT_FULL_VERSION)" -b manpage $<
endef

%.1: %.1.adoc
	$(ASCIIDOC_MANPAGE)
%.5: %.5.adoc
	$(ASCIIDOC_MANPAGE)
%.7: %.7.adoc
	$(ASCIIDOC_MANPAGE)
%.8: %.8.adoc
	$(ASCIIDOC_MANPAGE)
endif

# If ANOTRA_BIN not set, default to look for "npx" to run "npx antora".  If we
# end up with undefined ANTORA_BIN (i.e. not set and npx not found), we'll give
# a sane error when building docs below.
ifeq ($(ANTORA_BIN),)
NPX := $(shell command -v npx 2> /dev/null)
ifneq ($(NPX),)
ANTORA_BIN := "$(NPX) antora"
endif
endif
.PHONY: doc_site
doc_site: $(manpages) doc_site/modules/ROOT/nav.adoc doc_site/modules/ROOT/pages/index.adoc
ifndef ANTORA_BIN
	$(error Antora not found, install nodejs or set ANTORA_BIN to make doc site)
endif
	mkdir -p doc_site/modules/ROOT/pages/man
	cd doc_site/modules/ROOT/pages/man/; for i in $(manpages) man/dracut.usage; do ln -sf ../../../../../$${i}.adoc $(basename $i); done
	$(shell echo $(ANTORA_BIN)) --attribute "mainversion=$(DRACUT_MAIN_VERSION)" \
	  --attribute "version=${DRACUT_FULL_VERSION}" \
	  antora-playbook.yml

dracut.8: man/dracut.8.adoc \
	man/dracut.usage.adoc

dracut.pc: Makefile.inc Makefile
	@echo "Name: dracut" > dracut.pc
	@echo "Description: dracut" >> dracut.pc
	@echo "Version: $(DRACUT_FULL_VERSION)" >> dracut.pc
	@echo "dracutdir=$(pkglibdir)" >> dracut.pc
	@echo "dracutmodulesdir=$(pkglibdir)/modules.d" >> dracut.pc
	@echo "dracutconfdir=$(pkglibdir)/dracut.conf.d" >> dracut.pc

install: all
	mkdir -p $(DESTDIR)$(pkglibdir)
	mkdir -p $(DESTDIR)$(bindir)
	mkdir -p $(DESTDIR)$(sysconfdir)
	mkdir -p $(DESTDIR)$(pkglibdir)/modules.d
	mkdir -p $(DESTDIR)$(mandir)/man1 $(DESTDIR)$(mandir)/man5 $(DESTDIR)$(mandir)/man7 $(DESTDIR)$(mandir)/man8
	install -m 0755 dracut.sh $(DESTDIR)$(bindir)/dracut
	sed -i 's;^\(DRACUT_VERSION\)=".*"$$;\1="$(DRACUT_FULL_VERSION)";' $(DESTDIR)$(bindir)/dracut
	install -m 0755 dracut-catimages.sh $(DESTDIR)$(bindir)/dracut-catimages
	install -m 0755 lsinitrd.sh $(DESTDIR)$(bindir)/lsinitrd
	install -m 0644 dracut.conf $(DESTDIR)$(sysconfdir)/dracut.conf
	mkdir -p $(DESTDIR)$(sysconfdir)/dracut.conf.d
	mkdir -p $(DESTDIR)$(pkglibdir)/dracut.conf.d
	install -m 0755 dracut-functions.sh $(DESTDIR)$(pkglibdir)/dracut-functions.sh
	ln -fs dracut-functions.sh $(DESTDIR)$(pkglibdir)/dracut-functions
	install -m 0755 dracut-logger.sh $(DESTDIR)$(pkglibdir)/dracut-logger.sh
	install -m 0755 dracut-initramfs-restore.sh $(DESTDIR)$(pkglibdir)/dracut-initramfs-restore
	for module in modules.d/*; do \
		if test -L "$$module"; then cp -d "$$module" "$(DESTDIR)$(pkglibdir)/modules.d"; continue; fi; \
		install -m 0755 -d "$$module" "$(DESTDIR)$(pkglibdir)/$$module"; \
		for file in "$$module"/*; do \
			mode=0755; test -x "$$file" || mode=0644; \
			install -m "$$mode" "$$file" "$(DESTDIR)$(pkglibdir)/$$file"; \
		done; \
	done
	for conf in $(configs); do \
		install -D -m 0644 "dracut.conf.d/$$conf" "$(DESTDIR)$(pkglibdir)/dracut.conf.d/$$conf"; \
	done
	for i in $(configprofile) ; do \
		install -m 0644 dracut.conf.d/$$i/* $(DESTDIR)$(pkglibdir)/dracut.conf.d/ ;\
	done
ifeq ($(enable_test),yes)
	cp -a test $(DESTDIR)$(pkglibdir)
	for conf in $(test_configs); do \
		install -D -m 0644 "dracut.conf.d/$$conf" "$(DESTDIR)$(pkglibdir)/dracut.conf.d/$$conf"; \
	done
else
	rm -rf $(DESTDIR)$(pkglibdir)/modules.d/70test*
	rm -rf $(DESTDIR)$(pkglibdir)/dracut.conf.d/test*
endif
ifneq ($(enable_documentation),no)
	for i in $(man1pages); do install -m 0644 $$i $(DESTDIR)$(mandir)/man1/$${i##*/}; done
	for i in $(man5pages); do install -m 0644 $$i $(DESTDIR)$(mandir)/man5/$${i##*/}; done
	for i in $(man7pages); do install -m 0644 $$i $(DESTDIR)$(mandir)/man7/$${i##*/}; done
	for i in $(man8pages); do install -m 0644 $$i $(DESTDIR)$(mandir)/man8/$${i##*/}; done
	ln -fs dracut.cmdline.7 $(DESTDIR)$(mandir)/man7/dracut.kernel.7
endif
	if [ -n "$(systemdsystemunitdir)" ]; then \
		mkdir -p $(DESTDIR)$(systemdsystemunitdir); \
		ln -srf $(DESTDIR)$(pkglibdir)/modules.d/77dracut-systemd/dracut-shutdown-onfailure.service $(DESTDIR)$(systemdsystemunitdir)/dracut-shutdown-onfailure.service; \
		ln -srf $(DESTDIR)$(pkglibdir)/modules.d/77dracut-systemd/dracut-shutdown.service $(DESTDIR)$(systemdsystemunitdir)/dracut-shutdown.service; \
		mkdir -p $(DESTDIR)$(systemdsystemunitdir)/sysinit.target.wants; \
		ln -sf ../dracut-shutdown.service \
		$(DESTDIR)$(systemdsystemunitdir)/sysinit.target.wants/dracut-shutdown.service; \
		mkdir -p $(DESTDIR)$(systemdsystemunitdir)/initrd.target.wants; \
		for i in \
		    dracut-cmdline.service \
		    dracut-mount.service \
		    dracut-pre-mount.service \
		    dracut-pre-pivot.service \
		    dracut-pre-trigger.service \
		    dracut-pre-udev.service \
		    ; do \
			ln -srf $(DESTDIR)$(pkglibdir)/modules.d/77dracut-systemd/$$i $(DESTDIR)$(systemdsystemunitdir); \
			ln -sf ../$$i \
			$(DESTDIR)$(systemdsystemunitdir)/initrd.target.wants/$$i; \
		done; \
		ln -srf $(DESTDIR)$(pkglibdir)/modules.d/77initqueue/dracut-initqueue.service $(DESTDIR)$(systemdsystemunitdir); \
		ln -sf ../dracut-initqueue.service \
		$(DESTDIR)$(systemdsystemunitdir)/initrd.target.wants/dracut-initqueue.service; \
	fi
	if [ -f src/install/dracut-install ]; then \
		install -m 0755 src/install/dracut-install $(DESTDIR)$(pkglibdir)/dracut-install; \
	fi
	if [ -f src/skipcpio/skipcpio ]; then \
		install -m 0755 src/skipcpio/skipcpio $(DESTDIR)$(pkglibdir)/skipcpio; \
	fi
	if [ -f dracut-util ]; then \
		install -m 0755 dracut-util $(DESTDIR)$(pkglibdir)/dracut-util; \
	fi
ifeq ($(enable_dracut_cpio),yes)
	install -m 0755 dracut-cpio $(DESTDIR)$(pkglibdir)/dracut-cpio
endif
	mkdir -p $(DESTDIR)${prefix}/lib/kernel/install.d
	install -m 0755 install.d/50-dracut.install $(DESTDIR)${prefix}/lib/kernel/install.d/50-dracut.install
	install -m 0755 install.d/51-dracut-rescue.install $(DESTDIR)${prefix}/lib/kernel/install.d/51-dracut-rescue.install
	mkdir -p $(DESTDIR)${bashcompletiondir}
	install -m 0644 shell-completion/bash/dracut $(DESTDIR)${bashcompletiondir}/dracut
	install -m 0644 shell-completion/bash/lsinitrd $(DESTDIR)${bashcompletiondir}/lsinitrd
	mkdir -p $(DESTDIR)${pkgconfigdatadir}
	install -m 0644 dracut.pc $(DESTDIR)${pkgconfigdatadir}/dracut.pc
ifneq ($(enable_network_legacy),yes)
	rm -r $(DESTDIR)$(pkglibdir)/modules.d/[0-9][0-9]network-legacy
endif
	if ! [ -n "$(systemdsystemunitdir)" ]; then \
		rm -rf $(DESTDIR)$(pkglibdir)/test/TEST-[0-9][0-9]-*SYSTEMD* ;\
		rm -rf $(DESTDIR)$(pkglibdir)/modules.d/*systemd* $(DESTDIR)$(mandir)/man8/*.service.* ; \
		for i in bluetooth connman dbus* fido2 lvmmerge lvmthinpool-monitor memstrack pcsc pkcs11 rngd squash* tpm2-tss; do \
			rm -r $(DESTDIR)$(pkglibdir)/modules.d/[0-9][0-9]$${i}; \
		done \
	fi
ifneq ($(ARCH),s390x)
	for f in cio_ignore cms dasd dasd_mod dcssblk zfcp zipl znet; do \
		rm -r $(DESTDIR)$(pkglibdir)/modules.d/[0-9][0-9]$${f}; \
	done
else
	rm -r $(DESTDIR)$(pkglibdir)/modules.d/[0-9][0-9]warpclock
endif

clean:
	$(RM) *~
	$(RM) */*~
	$(RM) */*/*~
	$(RM) $(manpages:%=%.xml) dracut.xml
	$(RM) dracut-*.tar.bz2 dracut-*.tar.xz
	$(RM) dracut-install src/install/dracut-install $(DRACUT_INSTALL_OBJECTS)
	$(RM) src/skipcpio/skipcpio $(SKIPCPIO_OBJECTS)
	$(RM) dracut-util src/util/util $(UTIL_OBJECTS)
	$(RM) $(manpages)
	$(RM) dracut.pc
	$(RM) dracut-cpio src/dracut-cpio/target/release/dracut-cpio*
	$(RM) -rf build/ doc_site/modules/ROOT/pages/man/*
	$(MAKE) -C test clean

distclean: clean
	$(RM) Makefile.inc

.PHONY: bashcheck
bashcheck:
	@ret=0;for i in dracut-initramfs-restore.sh modules.d/*/*.sh; do \
                [ "$${i##*/}" = "module-setup.sh" ] && continue; \
                read line < "$$i"; [ "$${line#*bash*}" != "$$line" ] && continue; \
		[ $$V ] && echo "posix syntax check: $$i"; bash --posix -n "$$i" ; ret=$$(($$ret+$$?)); \
		[ $$V ] && echo "checking for [[: $$i"; if grep -Fq '[[ ' "$$i" ; then ret=$$(($$ret+1)); echo "$$i contains [["; fi; \
		[ $$V ] && echo "checking for echo -n: $$i"; if grep -Fq 'echo -n ' "$$i" ; then ret=$$(($$ret+1)); echo "$$i contains echo -n"; fi \
	done;exit $$ret
	@ret=0;for i in *.sh modules.d/*/*.sh modules.d/*/module-setup.sh; do \
		[ $$V ] && echo "bash syntax check: $$i"; bash -n "$$i" ; ret=$$(($$ret+$$?)); \
	done;exit $$ret

.PHONY: shellcheck
shellcheck:
ifeq ($(HAVE_SHFMT),yes)
	shellcheck $$(shfmt -f *)
else
	find * -name '*.sh' -print0 | xargs -0 shellcheck
endif

.PHONY: shellcheck-busybox
shellcheck-busybox:
ifeq ($(HAVE_SHFMT),yes)
	shellcheck -s busybox $$(shfmt -f * | test/filter-out-bash)
else
	find * -name '*.sh' | test/filter-out-bash | xargs shellcheck -s busybox
endif

.PHONY: syncheck
syncheck: bashcheck $(if $(filter yes,$(HAVE_SHELLCHECK)),shellcheck shellcheck-busybox)

check: all
	@$(MAKE) -C test check

AUTHORS:
	@git log | git shortlog --numbered --summary -e | while read -r a rest || [ -n "$$rest" ]; do echo "$$rest"; done > AUTHORS

CONTRIBUTORS:
	@git log | git shortlog $(DRACUT_MAIN_VERSION).. --numbered --summary -e | while read -r a rest || [ -n "$$rest" ]; do echo "- $$rest"; done
