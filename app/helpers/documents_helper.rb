module DocumentsHelper
  def sorted_snippets(document)
    snippets = document.address_blocks.map do |address_block|
      [address_block.start_idx, address_block.end_idx, address_block]
    end
    snippets.sort_by!(&:first)
  end

  def link_to_if_address_cache(text, url, address_block)
    ku = (
      address_block.events&.size > 0
    ) && (
      address_block.events.all? { |t| t.shape_with_definition_point&.source_type == 'KatastralniUzemi' }
    )

    # do not show popover for Katastralni Uzemi
    if ku
      content_tag(:span, text, class: 'ku')
    else
      # TODO: for showing unknown addresses with custom style
      # unknown = address_block.events.any? { |t| t.address_cache.blank? || t.shape_with_definition_point.nil? }
      event_classes = address_block.events.map { |e| "event-#{e.id}" }
      link_to(
        text,
        url,
        class: event_classes.join(' '), # + (unknown ? ' unknown-place' : ''),
        id: "addressBlock-#{address_block.id}",
        title: "<a href=\"#addressBlock-#{address_block.id}\">Adresy <i class=\"fa fa-link\"></a>",
        data: {
          toggle: 'popover',
          content: '<div class="inner"><i class="fa fa-spinner fa-spin"></i> Načítam...</div>',
          html: true
        }
      )
    end
  end
end
