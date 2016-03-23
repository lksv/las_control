var cancelFce = function() {
  $('#cancel-filter-all').on('click', function(event) {
    event.preventDefault();
    location.search='';
  });
};
var filter_documents = function() {
  $('#filter-documents').on('click', function(event) {
    event.preventDefault();
    location.search= $(event.target).data('search');
  });
};

var dateRangeInit = function() {
  if (!window.params) {
    decodeQParams();
  }
  var default_from_date = moment(params['from_date'], 'YYYY-MM-DD');
  if (!default_from_date.isValid()) {
    default_from_date = moment().subtract(1, 'years');
  }
  var default_to_date = moment(params['to_date'], 'YYYY-MM-DD');
  if (!default_to_date.isValid()) {
    default_to_date = moment();
  }
  $("#slider-range").slider({
    range: true,
    min: moment().subtract(2, 'years').unix(),
    max: moment().unix(),
    values: [ default_from_date.unix(), default_to_date.unix() ],
    slide: function( event, ui ) {
      var from_date = moment(ui.values[0] * 1000);
      var to_date = moment(ui.values[1] * 1000);
      var input = $('#q_range');
      input.val(
        from_date.format('l') +  " - " + to_date.format('l')
      );

      params['from_date'] = from_date.format('YYYY-MM-DD');
      params['to_date'] = to_date.format('YYYY-MM-DD');

      window.clearTimeout(input.data('timeout'));
      input.data("timeout", setTimeout(function () {
        geojsonTileLayer.redraw();
      }, 500));

      var url = location.origin +
        location.pathname + '?' +
        $.param(params) +
        location.hash;
      history.pushState('', '', url)
    }
  });
  $( "#q_range" ).val(
    moment($("#slider-range").slider("values", 0) * 1000).format('l') +
    " - " +
    moment($("#slider-range").slider("values", 1) * 1000).format('l')
  );
};

var queryButtonOnsubmit = function() {
  $('#filter_form').submit(function(e) {
    e.stopPropagation();
    e.preventDefault();
    params['q[query]'] = $('#q_query').val();
    location.search = $.param(params);
  });
}


$(document).ready(cancelFce);
$(document).on("page:load", cancelFce);


$(document).ready(filter_documents);
$(document).on("page:load", filter_documents);

$(document).ready(dateRangeInit);
$(document).on("page:load", dateRangeInit);


$(document).ready(queryButtonOnsubmit);
$(document).on("page:load", queryButtonOnsubmit);
