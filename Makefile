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

.PHONY: git-tree-or-index-is-dirty

image: $(log)

# fail if git tree or index are dirty
git-tree-or-index-is-dirty:
	@git diff-index --quiet HEAD

# clean app beam files to avoid mix warnings when running container:
# "warning: redefining module ..."
$(log): git-tree-or-index-is-dirty
	docker build -t $(image) . |tee $@
