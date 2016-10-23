var initSelect = function() {
  $( ".select2-ajax" ).each( function() {
      $(this).ajaxSelect();
  });
};

$(document).on("page:change", initSelect);
