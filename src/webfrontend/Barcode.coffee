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
		@__ratio = CUI.dom.div("cui-barcode-ratio")
		CUI.dom.append(@DOM, @__ratio)
		return @

	render: (data, convertToImage = false) ->
		isQR = @_type == ez5.Barcode.TYPE_QR
		if isQR
			@addClass("cui-barcode--matrix")

		if not data or not CUI.util.isString(data)
			if @_mode == "editor"
				@__replaceWithLabel("barcode.label.empty-data.#{@__getLocaType()}")
				return @
			CUI.dom.empty(@__ratio) # No data, other mode than editor, remove the barcode.
			return @

		if isQR
			data = data.toString()
			if data.length >= 1056 # More than 1056 the library throws an error.
				@__replaceWithLabel("barcode.label.qr-data-too-long")
				return @

			element = CUI.dom.div()
			new QRCode(element, data)

			img = CUI.dom.findElement(element, "img")
			CUI.dom.remove(img)
		else
			element = CUI.dom.$element("canvas")
			try
				JsBarcode(element, data,
					format: @_barcode_type
				)
			catch
				@__replaceWithLabel("barcode.label.wrong-data.#{@__getLocaType()}")
				return @

		if convertToImage
			# Overrides the element with an image of the barcode/qrcode.
			canvas = CUI.dom.findElement(element, "canvas")
			url = canvas.toDataURL()
			element = CUI.dom.element("img", src: url)

		CUI.dom.replace(@__ratio, element)
		return @

	__replaceWithLabel: (locaKey) ->
		label = new CUI.Label(text: $$(locaKey), centered: true, appearance: "secondary", size: "mini", multiline: true)
		CUI.dom.replace(@__ratio, label)
		return

	__getLocaType: ->
		return @_type.replace(/\s/g, "_").toLowerCase()