dist_file = URL-Copy.zip

js_engine ?= `which node nodejs`
jsdoc_toolkit = C:/jsdoc-toolkit
compiler = $(js_engine) build/uglify.js --unsafe
post_compiler = $(js_engine) build/post-compile.js
validator = $(js_engine) build/jslint-check.js

base_files = src/js/background.js\
    src/js/notification.js\
	src/js/options.js\
	src/js/popup.js\
	src/js/shortcuts.js\
	src/js/utils.js

base_bin_files = $(subst src/,bin/,$(base_files))
base_dirs = bin\
	bin/_locales\
	bin/css\
	bin/images\
	bin/js bin/pages
base_locale_dirs = bin/_locales/en\
	bin/_locales/fr

all: core dist

core: urlcopy $(bin_base_files)
	@@echo "URL-Copy build complete"

urlcopy: $(base_dirs) $(base_locale_dirs)
	@@echo "Building URL-Copy"
	@@mkdir -p bin
	@@cp -r src/* bin
	# TODO: Below doesn't work
	@@rm -rf bin/*.git*

$(bin_base_files): urlcopy
	# TODO: Files aren't being minimized
	@@if test ! -z $(js_engine); then \
		echo "Minifying: " $@; \
		$(compiler) $@ > $@.tmp; \
		$(post_compiler) $@.tmp > $@; \
		rm -f $@.tmp; \
		echo "Validating: " $@; \
		$(validator) $@; \
	else \
		echo "You must have NodeJS installed in order to minify and validate " $(notdir $@); \
	fi

$(base_dirs):
	@@mkdir -p $@

$(base_locale_dirs):
	@@mkdir -p $@

doc:
	@@echo "Generating documentation"
	@@mkdir -p docs
	@@java -jar $(jsdoc_toolkit)/jsrun.jar $(jsdoc_toolkit)/app/run.js -q -p -d=docs \
		-t=$(jsdoc_toolkit)/templates/jsdoc $(base_files)

dist: doc
	@@echo "Generating distributable"
	@@mkdir -p dist
	@@zip -r dist/$(dist_file) bin
	@@echo "URL-Copy distributable complete"

distclean: docclean
	@@echo "Removing distribution directory"
	@@rm -rf dist

docclean:
	@@echo "Removing documentation directory"
	@@rm -rf docs

clean: distclean
	@@echo "Removing binary directory"
	@@rm -rf bin

.PHONY: all urlcopy doc dist clean distclean docclean core