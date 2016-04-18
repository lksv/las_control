function initClearInputButton() {
  $(".clear-button").addClear({showOnLoad: true});
  $('a[data-toggle="tab"]').on('shown.bs.tab', initClearInputButton);
}

$(document).on("page:change", initClearInputButton);
