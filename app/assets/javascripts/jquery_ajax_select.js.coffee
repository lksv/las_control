# https://gist.github.com/smoil/5061616

jQuery.fn.ajaxSelect = (options) ->
  defaults =
    url: $(@).data('url')
    placeholder: "Search for a record"
    multiple: false
    allow_clear: true
    per: 20

  placeholder = $(@).data('placeholder')
  defaults.placeholder = placeholder if placeholder


  settings = $.extend(defaults, options)

  this.select2
    theme: "bootstrap"
    initSelection: (elm, callback) ->
      callback({"id":elm.data("id"), "text":elm.data("text")})
    escapeMarkup: (m) ->
      m
    placeholder: settings.placeholder
    allowClear: settings.allow_clear
    minimumInputLength: 3
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
