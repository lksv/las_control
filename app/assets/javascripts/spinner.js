//https://codediode.io/lessons/8736-loading-spinners-in-rails

// turbolinks
$(document).on("page:fetch", function(){
  $(".spinner").show();
});

$(document).on("page:receive", function(){
  $(".spinner").hide();
});
$(document).on("page:load", function(){
  $(".spinner").hide();
});



// ajax
$( document ).ready(function() {

  // hide spinner
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
