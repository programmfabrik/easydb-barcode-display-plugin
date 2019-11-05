class ez5.PdfBarcodeNode extends ez5.PdfNode

	@getName: ->
		"barcode"

	__renderPdfContent: (opts) ->
		object = opts.object
		if not object
			return

		data = @getData()
		if not data.field_name
			return


		fieldNameSplit = data.field_name.split(".")
		barcodesData = []
		getData = (_data, fieldNames) =>
			name = fieldNames[0]
			value = _data[name]
			fieldNames = fieldNames.slice(1)
			if CUI.util.isPlainObject(value)
				getData(value, fieldNames)
			else if CUI.util.isArray(value)
				for d in value
					getData(d, fieldNames)
				return
			else if CUI.util.isString(value)
				barcodesData.push(value)
			return
		getData(object, fieldNameSplit)

		if barcodesData.length == 0
			return

		barcodes = []
		for barcodeData in barcodesData
			barcode = new ez5.Barcode
				mode: "detail"
				type: data.code_type
				barcode_type: data.barcode_type
			barcode.render(barcodeData, true)
			barcodes.push(barcode)

		div = CUI.dom.div()

		columnGap = data.column_gap or 0
		barcodeWidth = data.barcode_width or "100%"

		rows = Math.ceil(barcodesData.length / data.columns)
		width = 100 / data.columns

		barcodesOffset = 0
		columnsOffset = data.columns
		for rowIndex in [0...rows]
			_barcodes = barcodes.slice(barcodesOffset, columnsOffset)
			if _barcodes.length == 0
				break
			barcodesOffset += data.columns
			columnsOffset += data.columns

			row = CUI.dom.div()
			for barcode in _barcodes
				CUI.dom.setStyle(barcode,
					width: "calc(#{width}% - #{columnGap}mm)"
					display: "inline-block"
					padding: "#{columnGap / 2}mm"
				)
				img = CUI.dom.children(barcode.DOM)[0]
				CUI.dom.setStyle(img, width: barcodeWidth)
				CUI.dom.append(row, barcode)
			CUI.dom.append(div, row)

		return div

	__getSettingsFields: ->
		idObjecttype = @__getIdObjecttype()
		fields = ez5.BarcodeMaskSplitter.getBarcodeOptions(idObjecttype, store_value: "fullname")
		fields.push(
			type: CUI.Select
			name: "columns"
			form: label: $$("pdf-creator.settings.barcode.columns-select|text")
			options: [
				value: 1
			,
				value: 2
			,
				value: 3
			,
				value: 4
			,
				value: 5
			]
		)
		fields.push(
			type: CUI.Input
			name: "column_gap"
			form: label: $$("pdf-creator.settings.barcode.column-gap|text")
		)
		fields.push(
			type: CUI.Input
			name: "barcode_width"
			form: label: $$("pdf-creator.settings.barcode.barcode-width|text")
			placeholder: $$("pdf-creator.settings.barcode.barcode-width|placeholder")
		)
		return fields

	__getStyleSettings: ->
		return ["class_name"]

ez5.PdfCreator.plugins.registerPlugin(ez5.PdfBarcodeNode)