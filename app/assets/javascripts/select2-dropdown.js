var initSelect = function() {
  $( ".select2-ajax" ).ajaxSelect();
};

$(document).on("page:change", initSelect);
