class ez5.BarcodeSearchExpertPlugin extends ez5.SearchExpertPlugin

	beforeFieldAdded: (opts) ->
		field = opts.field
		data = opts.data

		if CUI.util.isEmpty(data[field.name()])
			return

		if field?.mask
			fields = field.mask.getFields("all")
		else if field instanceof MultipleFieldsContainer and field.fields
			fields = []
			for _field in field.fields
				_fields = _field.mask.getFields("all")
				fields = fields.concat(_fields)
		else
			return

		for _field in fields
			if _field not instanceof ez5.BarcodeMaskSplitter
				continue

			dataOptions = _field.getDataOptions()
			if dataOptions?.field_name != field.name()
				continue

			limit = parseInt(dataOptions.expert_search_limit)
			if limit > 0
				data[field.name()] = data[field.name()].substring(0, limit)
		return

ez5.session_ready ->
	SearchExpertOptions.plugins.registerPlugin(ez5.BarcodeSearchExpertPlugin)
