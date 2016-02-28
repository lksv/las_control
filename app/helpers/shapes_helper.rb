module ShapesHelper
  def cuzk_url(ruian_source, link_text = 'KN ')
    cuzk_url = ruian_source.respond_to?(:cuzk_url) ? ruian_source.cuzk_url : nil
    if cuzk_url
      link_to cuzk_url, target: '_blank' do
        content_tag('span', class: 'cuzk') do
          (
            link_text + content_tag('i', '', class:'fa fa-external-link')
          ).html_safe
        end
      end
    end
  end
end
