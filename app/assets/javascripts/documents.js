$(document).on('page:change', function () {

  $('.toggle-pdf-view').click(function() {
    $(this).find('span').each(function() { $(this).toggle(); });
    $('#pdfViewColumn').toggle();
  });


  // following code is important only for documents#show view
  if ($('main.documents.show').length == 0) {
    return
  }
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
      // I cannot use trigger: 'focus', because it opens popover on navigating
      // to the page with anchor
      trigger:"click",
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


  //see http://stackoverflow.com/a/14857326
  //I cannot use trigger: 'focus' see above
  $('main.documents.show').on('click', function (e) {
      $('[data-toggle="popover"]').each(function () {
          //the 'is' for buttons that trigger popups
          //the 'has' for icons within a button that triggers a popup
          if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
              $(this).popover('hide');
          }
      });
  });
});
