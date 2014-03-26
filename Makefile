DOCKER_USERNAME := localhost.localdomain:5000
DOCKER_REPOSITORY := misfire

gitsha := $(shell git rev-parse --short HEAD)
gitref := $(shell git symbolic-ref --short -q HEAD || git describe --tags)

ifeq ($(gitref),master)
tag :=
else
tag := :$(gitref)
endif

image := $(DOCKER_USERNAME)/$(DOCKER_REPOSITORY)$(tag)
log = image-$(gitsha)-$(gitref).log

.PHONY: clean deps git-tree-or-index-is-dirty

deps:
	mix deps.get
	mix deps.compile

clean:
	mix clean

# fail if git tree or index are dirty
git-tree-or-index-is-dirty:
	@git diff-index --quiet HEAD

image: $(log)

# clean app beam files to avoid mix warnings when running container:
# "warning: redefining module ..."
$(log): git-tree-or-index-is-dirty deps clean
	docker build -t $(image) . |tee $@
