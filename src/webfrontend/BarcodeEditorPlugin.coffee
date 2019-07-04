class ez5.BarcodeEditorPlugin extends ez5.EditorPlugin
	checkForm: (opts) ->
		data = opts.resultObject.getData()[opts.resultObject.objecttype()]

		findBarcodes = (_data) ->
			for key, value of _data
				if CUI.util.isArray(value) # Nested values.
					for _value in value
						findBarcodes(_value)
					continue

				if not key.endsWith(":barcode") or value not instanceof ez5.Barcode
					continue

				_key = key.split(":barcode")[0]
				value.render(_data[_key])
		findBarcodes(data)

		return []

ez5.session_ready ->
	Editor.plugins.registerPlugin(ez5.BarcodeEditorPlugin)
