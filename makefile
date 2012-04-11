PROJECTFOLDER=fsqlf
SRC=src/*.d



.PHONY: all clean zip test test-print test-compare


#  BUILD
fsqlf: src/fsqlf.d src/configuration_types.d src/keyword.d src/keyword_conf.d
	cd src && dmd -unittest fsqlf.d configuration_types.d keyword.d keyword_conf.d
	mv ./src/fsqlf ./fsqlf


all: fsqlf


test: fsqlf
	./fsqlf


clean:
	rm -f src/*.o
	rm -f fsqlf


#  TESTING
TEST_SAMPLE=testing/sample.sql
TEST_TMP_ORIGINAL=testing/tmp_test_original.txt
TEST_TMP_FORMATED=testing/tmp_test_formated.txt

test-print:$(EXEC_CLI)
	./$(EXEC_CLI) $(TEST_SAMPLE) |  awk -F, '{ printf("%4d # ", NR) ; print}'

test-compare:$(EXEC_CLI) $(TEST_TMP_ORIGINAL) $(TEST_TMP_FORMATED)
	diff -i -E -b -w -B -q $(TEST_TMP_ORIGINAL) $(TEST_TMP_FORMATED)
$(TEST_TMP_ORIGINAL):
	cat        $(TEST_SAMPLE) |  tr '\n' ' ' | sed 's/[\t ]//g' | sed 's/outer//gi' | sed 's/inner//gi' > $(TEST_TMP_ORIGINAL)
$(TEST_TMP_FORMATED):
	./$(EXEC_CLI) $(TEST_SAMPLE) |  tr '\n' ' ' | sed 's/[\t ]//g' | sed 's/outer//gi' | sed 's/inner//gi' > $(TEST_TMP_FORMATED)

