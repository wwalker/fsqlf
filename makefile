PROJECTFOLDER=fsqlf

SRC=src/fsqlf.d src/tokenizer.d src/higher_types.d src/types.d src/preprocessor.d src/dbg.d src/parser.d



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
