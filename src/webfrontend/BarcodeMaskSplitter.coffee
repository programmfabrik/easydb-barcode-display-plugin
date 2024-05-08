class ez5.BarcodeMaskSplitter extends CustomMaskSplitter

    isSimpleSplit: ->
        return true

    renderAsField: ->
        return true

    getOptions: ->
        fieldSelectorOpts =
            store_value: "name"
            filter: (field) =>
                if not @father.children.some((_field) => _field.getData().field_name == field.name())
                    return false
                return true
        fields = ez5.BarcodeMaskSplitter.getBarcodeOptions(@maskEditor.getMask().getTable().table_id, fieldSelectorOpts)
        fields.push
            type: CUI.NumberInput
            form: label: $$("barcode.custom.splitter.options.expert_search_limit.label")
            name: "expert_search_limit"
            decimals: 0
        return fields

    @getBarcodeOptions: (idObjecttype, fieldSelectorOptions = {}) ->
        disableEnableBarcodeType = (field) ->
            form = field.getForm()
            data = form.getData()
            barcodeTypeField = form.getFieldsByName("barcode_type")[0]
            if data.code_type == ez5.Barcode.TYPE_BAR
                barcodeTypeField.enable()
            else
                barcodeTypeField.disable()
            return

        fieldSelectorFilter = fieldSelectorOptions.filter

        fieldSelector = new ez5.FieldSelector
            form: label: $$("barcode.custom.splitter.options.field-selector.label")
            name: "field_name"
            store_value: fieldSelectorOptions.store_value or "name"
            placeholder: $$("barcode.custom.splitter.options.field-selector.placeholder")
            objecttype_id: idObjecttype
            schema: "HEAD"
            filter: (field) =>
                
                # allow uuid, systemobjectid and globalobjectid
                if field.isTopLevelField()
                    if field instanceof SystemObjectIdColumn or 
                       field instanceof UuidColumn
                          return true
                
                # beyond that allow only simple text-fields on toplevel
                if fieldSelectorFilter and not fieldSelectorFilter?(field)
                    return false

                return field instanceof TextColumn and
                    field not instanceof DecimalColumn and
                    field not instanceof LinkColumn and
                    field not instanceof PrimaryKeyColumn and
                    field not instanceof LocaTextColumn and
                    field not instanceof TextMultiColumn and
                    not field.isTopLevelField()

        [
            type: CUI.Select
            name: "code_type"
            form: label: $$("barcode.custom.splitter.options.code-type.label")
            options: [
                text: $$("barcode.custom.splitter.options.code-type.barcode.text")
                value: ez5.Barcode.TYPE_BAR
            ,
                text: $$("barcode.custom.splitter.options.code-type.qrcode.text")
                value: ez5.Barcode.TYPE_QR
            ]
            onDataChanged: (_, field) ->
                disableEnableBarcodeType(field)
        ,
            type: CUI.Select
            name: "barcode_type"
            form:
                label: $$("barcode.custom.splitter.options.barcode-type.label")
                hint: $$("barcode.custom.splitter.options.barcode-type.hint")
            onRender: (field) ->
                disableEnableBarcodeType(field)
            options: ->
                options = []
                # Barcodes available https://github.com/lindell/JsBarcode/wiki#barcodes
                for option in [ez5.Barcode.DEFAULT_BARCODE_TYPE, "CODE39", "ITF14", "MSI", "pharmacode", "codabar", "EAN13", "UPC", "EAN8", "EAN5", "EAN2"]
                    options.push(value: option)
                return options
        ,
            type: CUI.Input
            name: "code_prefix"
            form:
                label: $$("barcode.custom.splitter.options.code_prefix.label")
                hint: $$("barcode.custom.splitter.options.code_prefix.hint")
        ,
            fieldSelector
        ,
            type: CUI.Input
            name: "code_suffix"
            form:
                label: $$("barcode.custom.splitter.options.code_suffix.label")
                hint: $$("barcode.custom.splitter.options.code_suffix.hint")
        ]

    renderField: (opts) ->
        fieldName = @getDataOptions().field_name
        if not fieldName # Not configured.
            return
    
        if fieldName in ['_uuid', '_system_object_id', '_global_object_id']
            _data = opts.top_level_data
            data = _data[fieldName]
        else
            _data = opts.data
            data = _data[fieldName]
        
        # add prefix and suffix if given
        if @.opts?.options?.code_prefix
            data = @.opts.options.code_prefix + data
        if @.opts?.options?.code_suffix
            data = data + @.opts.options.code_suffix
            
        barcode = new ez5.Barcode
            type: @getDataOptions().code_type
            barcode_type: @getDataOptions().barcode_type
            mode: opts.mode
        barcode.render(data)

    hasContent: (opts) ->
        fieldName = @getDataOptions().field_name
        if not fieldName # Not configured.
            return false
        data = opts.data[fieldName]
        return !!data

        _data["#{fieldName}:barcode"] = barcode
        return barcode

    isEnabledForNested: ->
        return true

MaskSplitter.plugins.registerPlugin(ez5.BarcodeMaskSplitter)
