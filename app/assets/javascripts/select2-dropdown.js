var initSelect = function() {
  $( ".select2-ajax" ).ajaxSelect();
};

$(document).ready(initSelect);
$(document).on("page:load", initSelect);

