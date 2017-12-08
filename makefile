EXE=lithpc

build:
	dub build

clean:
	dub clean

run:
	./$(EXE) ./test/print.lth

tst:
	find ./test/*.lth | xargs -n1 ./$(EXE)
