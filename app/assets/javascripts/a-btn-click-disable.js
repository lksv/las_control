function do_nothing() {
  return false;
}

function disableButtonLinkAfterClick() {
  $(document).on('click', 'a.btn', function(e) {
    var button = $(e.target).closest('a.btn');
    button.children('i.fa').remove();
    button.prepend('<i class="fa fa-refresh fa-spin"></i> ');
    button.addClass('disabled');
    button.click(do_nothing);
    setTimeout(function(){
      $(e.target).unbind('click', do_nothing);
    }, 10000);
  });
}


$(document).on("page:change", disableButtonLinkAfterClick);
