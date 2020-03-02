class ez5.BarcodeSearchExpertPlugin extends ez5.SearchExpertPlugin

	beforeFieldAdded: (opts) ->
		field = opts.field
		data = opts.data

		if CUI.util.isEmpty(data[field.name()])
			return

		for _field in field.mask.getFields("all")
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
