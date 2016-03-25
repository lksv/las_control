window.initAjaxEvents = function() {
  $(document).on('ajax:error', 'a,form', function(e,xhr, status, error) {
    console.log(e, xhr, status, error);
    $('#errorMessage').html(
      '<div class="alert alert-danger" role="alert">Ups. Stalo se něco nečekaného. Server odpovídá s chybou: ' +
      (error || 'Server neodpovídá') +
      '</div>'
    );
  });
}

$(document).on("page:change", initAjaxEvents);
