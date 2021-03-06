GITHUB=$(shell opam config var github:installed)
APP=Datakit.app
EXE=Datakit

TESTS = true

.PHONY: all clean test bundle COMMIT exe

all: datakit client github
	@

datakit:
	ocaml pkg/pkg.ml build --tests $(TESTS) -q

client:
	ocaml pkg/pkg.ml build -n datakit-client -q

github:
	ocaml pkg/pkg.ml build -n datakit-github -q

docs:
	ocamlbuild -use-ocamlfind doc/api.docdir/index.html

clean:
	ocaml pkg/pkg.ml clean
	rm -rf $(APP) $(EXE) _tests
	rm -f com.docker.db

test:
	ocaml pkg/pkg.ml build --tests true
	ocaml pkg/pkg.ml test

bundle:
	opam remove tls ssl -y
	$(MAKE) clean
	ocaml pkg/pkg.ml build --tests false --pinned true
	mkdir -p $(APP)/Contents/MacOS/
	mkdir -p $(APP)/Contents/Resources/lib/
	cp _build/src/bin/main.native $(APP)/Contents/MacOS/com.docker.db
	./scripts/check-dylib.sh
	dylibbundler -od -b \
	 -x $(APP)/Contents/MacOS/com.docker.db \
	 -d $(APP)/Contents/Resources/lib \
	 -p @executable_path/../Resources/lib
	cp $(APP)/Contents/MacOS/com.docker.db .

COMMIT:
	@git rev-parse HEAD > COMMIT

exe:
	opam remove tls ssl -y
	rm -rf _build/
	ocaml pkg/pkg.ml build --tests false --pinned true
	mkdir -p $(EXE)
	cp _build/src/bin/main.native $(EXE)/datakit.exe
	cp /usr/x86_64-w64-mingw32/sys-root/mingw/bin/zlib1.dll $(EXE)
