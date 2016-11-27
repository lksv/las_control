var CategoryLegend = function CategoryLegend() {
  this.color_map = {};
  this.selected_values = [];
  this.select2_selector = '#q_tags_filter';
}

CategoryLegend.prototype.fill_categories_legend_list = function(div) {
  var that = this;
  $.ajax({
    url: "/categories",
    context: document.body,
    dataType: 'json',
  }).done(function(data) {
      var html = '';

      $(data).each(function(index, item) {
        html += '<label style="font-weight:normal">'
        if (item.key != 'unknown') {
          html += '<input class="category-legend-checkbox" style="margin-left:5px;" type="checkbox" data-text="' + item.label + '" name="' + item.key + '" value="' + item.key + '"/>';
        }
        html += '<i style="background:' + item.color +'; margin: 1px; font-weight: bold; text-align: center;"></i>';
        html += '<span style="padding-left:5px;">' + item.label + '</span>'
        html += '</label>'
        html += '<br style="clear:left;">'

        that.color_map[item.key] = item.color;
      });

      $("#category_legend_loading", $(div)).replaceWith(html);
      $('.category-legend-checkbox').change(function(e) {
        that.apply_selected_category(e.target);
      });

      that.load_selected_values();
      that.subscribe_to_form();
  });
};

CategoryLegend.prototype.load_window_content = function(map) {
  var that = this;
  this.category_legend_control = L.control({position: 'bottomleft'});
  this.category_legend_control.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'info legend');

    div.innerHTML =
      '<div>' +
        '<div style="font-weight: bold; font-size: 0.9em;padding-bottom:3px;">Kategorie</div>' +
        '<div style="display: inline-block; vertical-align: middle; padding-right: 5px;">' +
          '<div id="category_legend_loading">' +
            '<span class="fa fa-spinner fa-spin"></span>' +
            '<span style="margin-left: 3px;">Načítám</span>' +
          '</div>' +
        '</div>' +
        '<div style="display: inline-block; vertical-align: middle; text-align: center;"></div>' +
      '</div>';

    that.fill_categories_legend_list(div);

    return div;
  };

  return this.category_legend_control;
};

CategoryLegend.prototype.apply_selected_category = function(changed_element) {
  var changed_element_jq = $(changed_element);
  var select2_selected_values = $(this.select2_selector).select2('val')
  var selected_category_key = changed_element_jq.val();

  if (changed_element_jq.prop('checked')) {
    //insert into data-init in select2, so select2 knows text to display for selected id
    $(this.select2_selector).data().init[selected_category_key] = changed_element_jq.data('text')
    select2_selected_values.push(selected_category_key);
  }
  else {
    select2_selected_values = select2_selected_values.filter( function(selected_value) {
      return selected_value != selected_category_key
    });
  }

  $(this.select2_selector).select2('val', select2_selected_values, true);
};

CategoryLegend.prototype.subscribe_to_form = function() {
  $(this.select2_selector).on('change', function(evt) {
    if (evt.added) {
      $('input[name="' + evt.added.id + '"]').prop('checked', true);
    }
    else {
      $('input[name="' + evt.removed.id + '"]').prop('checked', false);
    }

  });
};

// first save after page load
CategoryLegend.prototype.load_selected_values = function() {
  var selected_values = $(this.select2_selector).val().split(',');

  $.each(selected_values, function(index, value) {
    $('input[name="' + value + '"]').prop('checked', true);
  });
};

CategoryLegend.prototype.tag2color = function(tag) {
  return this.color_map[tag];
}
