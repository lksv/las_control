module AddressBlocksHelper
  def map_params_to_url(params)
    map_url(
      params: params.except(:zoom, :lat, :lng),
      anchor: "#{params[:zoom]}/#{params[:lat]}/#{params[:lng]}"
    )
  end
end
