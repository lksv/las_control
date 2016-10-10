var initSelect = function() {
  $( ".select2-ajax" ).each( function() {
      multiple = $(this).prop('multiple') || false;
      $(this).ajaxSelect({
        multiple: multiple,
      });
  });
};

$(document).on("page:change", initSelect);
