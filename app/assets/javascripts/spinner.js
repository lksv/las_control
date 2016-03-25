//https://codediode.io/lessons/8736-loading-spinners-in-rails

$(document).on("page:change", function() {
  $(".spinner").hide();
  // show spinner on AJAX start
  $(document).ajaxStart(function(){
    $(".spinner").show();
  });

  // hide spinner on AJAX stop
  $(document).ajaxStop(function(){
    $(".spinner").hide();
  });
});
