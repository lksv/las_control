# https://gist.github.com/smoil/5061616

jQuery.fn.ajaxSelect = (options) ->
  defaults =
    url: $(@).data('url')
    placeholder: "Search for a record"
    multiple: $(@).data('multiple')
    allow_clear: true
    per: 20
    minimumInputLength: $(@).data('minimumInputLength') || 3

  placeholder = $(@).data('placeholder')
  defaults.placeholder = placeholder if placeholder

  settings = $.extend(defaults, options)

  this.select2
    theme: "bootstrap"
    initSelection: (elm, callback) ->
      if settings.multiple
        data = []
        if elm.val() == ""
          callback(data);
          return;

        $.each elm.val().split(","), (i, id) ->
          data.push
            id: id
            text: elm.data('init')[id]

        callback(data)
      else
        callback({"id":elm.data("id"), "text":elm.data("text")})
    escapeMarkup: (m) ->
      m
    placeholder: settings.placeholder
    allowClear: settings.allow_clear
    multiple: settings.multiple
    processResults: (data) ->
      { results: data }
    ajax:
      url: settings.url
      dataType: "json"
      quietMillis: 100
      data: (term, page) ->
        query: term
        per: settings.per
        page: page
      results: (data, page) ->
        results: data
        more: (data.length == settings.per)
    formatResult: settings.formatter
    formatSelection: settings.formatter
