module EventsHelper
  include AddressBlocksHelper

  def show_event(event)
    loc = event.url_location_params
    if loc.blank?
      event.address_cache
    else
      link_to event.address_cache, map_params_to_url(loc)
    end
  end
end
