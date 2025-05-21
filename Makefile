.PHONY: build install uninstall reinstall clean

FINDLIB_NAME=memcpy
MOD_NAME=memcpy

OCAML_LIB_DIR=$(shell ocamlc -where)
CTYPES_LIB_DIR=$(shell ocamlfind query ctypes)
EXT_DLL=$(shell ocamlc -config | grep "ext_dll" | cut -d' ' -f2)
EXT_LIB=$(shell ocamlc -config | grep "ext_lib" | cut -d' ' -f2)

OCAMLBUILD=CTYPES_LIB_DIR=$(CTYPES_LIB_DIR) ocamlbuild -use-ocamlfind -classic-display

TARGETS=.cma .cmxa

PRODUCTS=$(addprefix $(MOD_NAME),$(TARGETS))
PRODUCTS+=$(addprefix $(MOD_NAME),$(TARGETS)) \
          lib$(MOD_NAME)_stubs.a dll$(MOD_NAME)_stubs$(EXT_DLL) \

TYPES=.mli .cmi .cmti .cmx

INSTALL:=$(addprefix $(MOD_NAME),$(TYPES)) \
         $(addprefix $(MOD_NAME),$(TARGETS))

INSTALL:=$(addprefix _build/lib/,$(INSTALL))

ARCHIVES:=_build/lib/$(MOD_NAME)$(EXT_LIB)

ARCHIVES+=_build/lib/$(MOD_NAME)$(EXT_LIB)

build:
	$(OCAMLBUILD) $(PRODUCTS)

install:
	ocamlfind install $(FINDLIB_NAME) META \
		$(INSTALL) \
		-dll _build/lib/dll$(MOD_NAME)_stubs$(EXT_DLL) \
		-nodll _build/lib/lib$(MOD_NAME)_stubs$(EXT_LIB) \
		$(ARCHIVES)

test: build
	$(OCAMLBUILD) lib_test/test.native
	./test.native

uninstall:
	ocamlfind remove $(FINDLIB_NAME)

reinstall: uninstall install

clean:
	ocamlbuild -clean
