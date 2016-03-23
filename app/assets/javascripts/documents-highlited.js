$(document).ready( function() {
  $('[data-toggle="popover"]').click(function(e) {
    e.preventDefault();
  });
  $('[data-toggle="popover"]').each(function(){
    $(this).popover({
      trigger:"focus",
      placement: function (context, source) {
        var obj = $(source);
        $.get(obj.attr("href"),function(d) {
          $(context).find('.inner').replaceWith(d);
        });
        return 'auto bottom';
      },
      html:true,
      content:"loading"
    });
  });
})
