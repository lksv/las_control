var CategoryLegend = {
  fill_categories_legend_list: function(div) {
    $.ajax({
      url: "/categories",
      context: document.body,
      dataType: 'json',
    }).done(function(data) {
        var html = '';

        $(data).each(function(index, item) {
          html += '<i style="background:' + item.color +'; margin: 1px; font-weight: bold; text-align: center;"></i>';
          html += '<span style="padding-left:5px;">' + item.label + '</span>'
          html += '<br style="clear:left;">'
        });

        $("#category_legend_loading", $(div)).replaceWith(html);
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
  }
};
