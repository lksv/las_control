var CategoryLegend = {

  select2_selector: '#q_tags_filter',

  fill_categories_legend_list: function(div) {
    $.ajax({
      url: "/categories",
      context: document.body,
      dataType: 'json',
    }).done(function(data) {
        var html = '';

        $(data).each(function(index, item) {
          if (item.key != 'unknown') {
            html += '<input type="checkbox" data-text="' + item.label + '" name="' + item.key + '" value="' + item.key + '" onchange="CategoryLegend.apply_selected_category(this)"/>';
          }
          html += '<i style="background:' + item.color +'; margin: 1px; font-weight: bold; text-align: center;"></i>';
          html += '<span style="padding-left:5px;">' + item.label + '</span>'
          html += '<br style="clear:left;">'
        });

        $("#category_legend_loading", $(div)).replaceWith(html);

        CategoryLegend.load_selected_values();
        CategoryLegend.subscribe_to_form();
    });
  },

  load_window_content: function() {
    var category_legend = L.control({position: 'bottomleft'});
    category_legend.onAdd = function (map) {
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

      CategoryLegend.fill_categories_legend_list(div);

      return div;
    };

    return category_legend;
  },

  apply_selected_category: function(changed_element) {
    var jq_selected_element = $(changed_element);
    //var data_array = $(this.select2_selector).select2.data();
    var element_value_array = $(this.select2_selector).select2('val')
    var id = jq_selected_element.val();

    //console.log($(this.select2_selector).data().init);
    //console.log($(this.select2_selector).select2('data-init'));
    //return;
    //console.log(element_value_array);

    if (jq_selected_element.prop('checked')) {
      //data_array.push({ id: id, text: jq_selected_element.data('text') });
      $(this.select2_selector).data().init[id] = jq_selected_element.data('text')
      element_value_array.push(id);
    }
    else {
      //data_array = data_array.filter( function(element) { return element.id != id });
      element_value_array = element_value_array.filter( function(element) { return element != id });
    }

    //$(this.select2_selector).select2('data', data_array);
    //console.log(element_value_array);
    $(this.select2_selector).select2('val', element_value_array, true);
  },

  subscribe_to_form: function() {
    $(this.select2_selector).on('change', function(evt) {
      //console.log(evt);

      if (evt.added) {
        $('input[name="' + evt.added.id + '"]').prop('checked', true);
      }
      else {
        $('input[name="' + evt.removed.id + '"]').prop('checked', false);
      }

    });
  },

  load_selected_values: function() {
    var selected_values = $(this.select2_selector).val().split(',');

    $.each(selected_values, function(index, value) {
      $('input[name="' + value + '"]').prop('checked', true);
    });
  }
};
