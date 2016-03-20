module MapHelper
  def show_event_source_link(source)
    title = source.title
    short_title = truncate(title, length: 40)
    data = { :'no-turbolink' => 'true' }
    data.update(toggle: 'tooltip', title: title) if short_title != title
    link_to short_title, polymorphic_path(source), data: data
  end
end
