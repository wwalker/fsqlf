PROJECTFOLDER=fsqlf

SRC=src/fsqlf.d
SRC+=src/lex/*.d
SRC+=src/ast/*.d
SRC+=src/dbg.d
SRC+=src/higher_types.d src/types.d



.PHONY: all clean zip test test-print test-compare


#  BUILD
fsqlf: $(SRC)
	dmd -w -unittest -offsqlf $(SRC)

fsqlf-gdb: $(SRC)
	dmd -w -unittest -g -debug=1 $(SRC)


all: fsqlf


test: fsqlf
	./fsqlf


clean:
	rm -f src/*.o
	rm -f fsqlf
