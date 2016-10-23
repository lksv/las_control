var cancelFce = function() {
  $('#cancel-filter-all').on('click', function(event) {
    event.preventDefault();
    location.search='';
  });
};
var filterDocuments = function() {
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

  var q_range = $("#q_range");
  q_range.daterangepicker({
    startDate: default_from_date,
    endDate: default_to_date,
    ranges: {
      'Posledních 7 dní': [moment().subtract(6, 'days'), moment()],
      'Poslední mesíc': [moment().subtract(1, 'month'), moment()],
      'Poslední 2 měsíce': [moment().subtract(2, 'month').startOf('month'), moment()],
      'Posledního půl roku': [moment().subtract(6, 'month').startOf('month'), moment()],
      'Poslední rok': [moment().subtract(1, 'year'), moment()],
      'Poslední 2 roky': [moment().subtract(2, 'year'), moment()],
      'Posledních 10 let': [moment().subtract(10, 'year'), moment()]
    },
    locale: {
      format: 'DD.MM.YYYY',
      separator: ' - ',
      applyLabel: 'Použít',
      cancelLabel: 'Zrušit',
      weekLabel: 'T',
      customRangeLabel: 'Vlastní výběr',
    },
    minDate: moment().subtract(10, 'years'),
    maxDate: moment().subtract(1, 'day'),
    showDropdowns: true
  });
  q_range.on('change', function() {
    var picker = q_range.data('daterangepicker');

    params.from_date = picker.startDate.format('YYYY-MM-DD');
    params.to_date = picker.endDate.format('YYYY-MM-DD');

    //redraw map
    if (q_range.data('timeout')) {
      window.clearTimeout(q_range.data('timeout'));
    }
    q_range.data("timeout", setTimeout(function () {
      geojsonTileLayer.redraw();
    }, 100));


    //update url
    var url = location.origin +
      location.pathname + '?' +
      $.param(params) +
      location.hash;
    history.pushState('', '', url)
  });
};

var lauChangeInit = function() {
  var q_lau_id = $("#q_lau_id");
  q_lau_id.on('change', function() {
    params['q[lau_id_eq]'] = $('#q_lau_id').val();

    geojsonTileLayer.redraw();

    //update url
    var url = location.origin +
      location.pathname + '?' +
      $.param(params) +
      location.hash;
    history.pushState('', '', url)
  });
}

var tagsChangeInit = function() {
  var q_lau_id = $("#q_tags_filter");
  q_lau_id.on('change', function() {
    params['q[tags_filter]'] = $('#q_tags_filter').val();

    geojsonTileLayer.redraw();

    //update url
    var url = location.origin +
      location.pathname + '?' +
      $.param(params) +
      location.hash;
    history.pushState('', '', url)
  });
}


var queryButtonOnsubmit = function() {
  $('#filter_form').submit(function(e) {
    e.stopPropagation();
    e.preventDefault();
    params['q[query]'] = $('#q_query').val();
    params.activeTab = 'filter';

    queryFilter.setQuery(params['q[query]']);

    var url = location.origin +
      location.pathname + '?' +
      $.param(params) +
      location.hash;
    history.pushState('', '', url)

  });
}



$(document).on("page:change", cancelFce)
$(document).on("page:change", filterDocuments)
$(document).on("page:change", dateRangeInit)
$(document).on("page:change", lauChangeInit)
$(document).on("page:change", tagsChangeInit)
$(document).on("page:change", queryButtonOnsubmit)
