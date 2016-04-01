$(document).ready(function () {
  // calculate margin of fixed document info header
  var fixedOffset = $(".doc-head-info").innerHeight() + 5;

  $("div.plain-text-row").css('margin-top', '' + fixedOffset + 'px');
  if ($(location.hash).length) {
    jQuery('html,body')
      .animate({scrollTop: $(location.hash ).offset().top - fixedOffset - 51}, 300);
  }

  //popover - make popover content ajax loadable
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
