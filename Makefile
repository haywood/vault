#export PATH := $(PWD)/bin:$(PATH)
export DEBUG := true

tests := $(wildcard test/test_*.sh)

test: $(foreach test,$(tests),$(patsubst test/%.sh,%,$(test)))

install:
	python setup.py install

dist:
	python setup.py sdist

clean:
	rm -rf build dist

dev:
	tar -cf - gpg_params.txt Dockerfile | sudo docker build -t vault-dev -
	sudo docker run --rm -t -i -v $(PWD):/opt/vault vault-dev /bin/bash

test_%: install
	./test/run.sh ./test/$@.sh

.PHONY: test dev
