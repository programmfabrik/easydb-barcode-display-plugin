class ez5.Barcode extends CUI.DOMElement

	@TYPE_QR = "QR code"
	@TYPE_BAR = "Barcode"

	@DEFAULT_BARCODE_TYPE = "CODE128"

	initOpts: ->
		super()
		@addOpts
			type:
				check: [ez5.Barcode.TYPE_BAR, ez5.Barcode.TYPE_QR]
				default: ez5.Barcode.TYPE_BAR
			barcode_type:
				check: String
				default: ez5.Barcode.DEFAULT_BARCODE_TYPE
			mode:
				check: String

	constructor: (opts) ->
		super(opts)

		@registerDOMElement(CUI.dom.div())
		return @

	render: (data) ->
		if not data or not CUI.util.isString(data)
			if @_mode == "editor"
				@__replaceWithEmptyDataLabel()
				return @
			CUI.dom.empty(@DOM) # No data, other mode than editor, remove the barcode.
			return @

		if @_type == ez5.Barcode.TYPE_BAR
			element = CUI.dom.$element("canvas", "ez5-barcode")
			try
				JsBarcode(element, data,
					format: @_barcode_type
				)
			catch
				@__replaceWithEmptyDataLabel()
				return @
		else
			data = data.toString()
			if data.length >= 1056 # More than 1056 the library throws an error.
				label = new CUI.Label(text: $$("barcode.label.qr-data-too-long"), centered: true, appearance: "secondary")
				CUI.dom.replace(@DOM, label)
				return @

			element = CUI.dom.div("ez5-qrcode")
			new QRCode(element, data)

		CUI.dom.replace(@DOM, element)
		return @

	__replaceWithEmptyDataLabel: ->
		label = new CUI.Label(text: $$("barcode.label.empty-data"), centered: true, appearance: "secondary")
		CUI.dom.replace(@DOM, label)
		return