SUBDIRS	:=	$(shell ls | egrep -v '^(\.git)$$')

all: make-all
	@rm -rf build
	@mkdir -p build
	@find . -name "*.sfc" -exec cp -fv {} build \;

make-all:
	@for i in $(SUBDIRS); do if test -e $$i/makefile ; then $(MAKE) -C $$i || {exit 1;} fi; done;

clean:
	@rm -rf build
	@for i in $(SUBDIRS); do if test -e $$i/makefile ; then $(MAKE) -C $$i clean || {exit 1;} fi; done;

