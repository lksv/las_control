module DocumentsHelper
  def sorted_snippets(document)
    snippets = document.address_blocks.map do |address_block|
      [address_block.start_idx, address_block.end_idx, address_block]
    end
    snippets.sort_by!(&:first)
  end
end
