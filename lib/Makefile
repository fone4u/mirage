.PHONY: all unix clean

JOBS ?= -j 4
OFLAGS ?= -classic-display

OS = $(shell uname -s | tr '[A-Z]' '[a-z]' | sed -e 's/darwin/macosx/g')
ARCH = $(shell uname -m)
#NODE = $(shell ocamlfind query js_of_ocaml 2>/dev/null)

ifeq ($(OS) $(ARCH),linux x86_64)
XEN_BUILD=xen-direct-xen
XEN_DOC=xen-direct-doc
endif

ifeq ($(NODE),)
NODE_BUILD=
else
NODE_BUILD=node-socket
endif

all: $(XEN_BUILD) unix-socket-unix unix-direct-unix
	@ :

doc: $(XEN_DOC) unix-socket-doc unix-direct-doc
	@ :

unix-direct-%:
	@mkdir -p _build
	@env MIRAGEOS=unix MIRAGEFLOW=direct ocamlbuild $(OFLAGS) $(JOBS) $*.otarget

unix-socket-%:
	@mkdir -p _build
	@env MIRAGEOS=unix MIRAGEFLOW=socket ocamlbuild $(OFLAGS) $(JOBS) $*.otarget

xen-direct-%:
	@mkdir -p _build
	@env MIRAGEOS=xen MIRAGEFLOW=direct ocamlbuild $(OFLAGS) $(JOBS) $*.otarget

node-socket:
	@mkdir -p _build
	@env MIRAGEOS=node MIRAGEFLOW=socket ocamlbuild $(OFLAGS) $(JOBS) node.otarget

clean:
	@ocamlbuild -clean
