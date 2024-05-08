PLUGIN_NAME = easydb-barcode-display
PLUGIN_PATH = easydb-barcode-display-plugin

EASYDB_LIB = easydb-library
L10N_FILES = l10n/$(PLUGIN_NAME).csv
L10N_GOOGLE_KEY = 1Z3UPJ6XqLBp-P8SUf-ewq4osNJ3iZWKJB83tc6Wrfn0
L10N_GOOGLE_GID = 1206465100

INSTALL_FILES = \
	$(WEB)/l10n/cultures.json \
	$(WEB)/l10n/de-DE.json \
	$(WEB)/l10n/en-US.json \
	$(CSS) \
	$(JS) \
	manifest.yml

COFFEE_FILES = \
    src/webfrontend/Barcode.coffee \
    src/webfrontend/BarcodeMaskSplitter.coffee \
	src/webfrontend/BarcodeEditorPlugin.coffee \
	src/webfrontend/BarcodeSearchExpertPlugin.coffee

all: build

include $(EASYDB_LIB)/tools/base-plugins.make

THIRDPARTY_FILES = \
	src/thirdparty/qrcode/qrcode.min.js \
	src/thirdparty/jsbarcode/JsBarcode.all.min.js

# Override ${JS} to include THIRDPARTY libraries and do not remove them with make clean.
${JS}: $(THIRDPARTY_FILES) $(subst .coffee,.coffee.js,${COFFEE_FILES})
	mkdir -p $(dir $@)
	cat $^ > $@

build: code $(L10N) copycss buildinfojson

code: $(JS) $(THIRDPARTY_FILES)

clean: clean-base

wipe: wipe-base

copycss: 
	mkdir -p build/webfrontend
	cp src/webfrontend/css/easydb-barcode-display.css build/webfrontend/easydb-barcode-display.css