var initSelect = function() {
  $( ".select2-ajax" ).ajaxSelect();
};

$(document).ready(function() { initSelect() });
$(document).on("page:load", function(){ initSelect() });

