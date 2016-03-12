module ShapesHelper
  def cuzk_url(shape, link_text = 'KN ')
    cuzk_url = shape.cuzk_url_cache
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
