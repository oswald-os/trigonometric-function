AUTOMAKE_OPTIONS = foreign
bin_PROGRAMS = trigFunc
trigFunc_SOURCES = main.cpp FuncA.cpp FuncA.h HTTP_Server.cpp
trigFunc_LDFLAGS = -static
dist_man_MANS = trigFunc.1

SUBDIRS = tests

CTRLF_DIR=$(CURDIR)/deb/DEBIAN
CTRLF_NAME=$(CTRLF_DIR)/control

.PHONY: deb debug

deb:
	mkdir -p $(CTRLF_DIR)
	echo Package: $(PACKAGE) > $(CTRLF_NAME)
	echo Version: $(VERSION) >> $(CTRLF_NAME)
	echo Architecture: all >> $(CTRLF_NAME)
	echo Maintainer: $(PACKAGE_BUGREPORT) >> $(CTRLF_NAME)
	echo -n "Description: " >> $(CTRLF_NAME)
	cat trigFunc.1 >> $(CTRLF_NAME)
	make DESTDIR=$(CURDIR)/deb install

debug:
	$(foreach v, $(.VARIABLES), $(info $(v)=$($(v))))
