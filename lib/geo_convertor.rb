class GeoConvertor
  def self.tile2bounding_box(zoom, x, y)
    n = 2.0 ** zoom

    lon_deg1 = x / n * 360.0 - 180.0
    lat_rad1 = Math::atan(Math::sinh(Math::PI * (1 - 2 * y / n)))
    lat_deg1 = 180.0 * (lat_rad1 / Math::PI)

    lon_deg2 = (x + 1) / n * 360.0 - 180.0
    lat_rad2 = Math::atan(Math::sinh(Math::PI * (1 - 2 * (y + 1) / n)))
    lat_deg2 = 180.0 * (lat_rad2 / Math::PI)

    {
      lat1: lat_deg1, lng1: lon_deg1,
      lat2: lat_deg2, lng2: lon_deg2
    }
  end
end
