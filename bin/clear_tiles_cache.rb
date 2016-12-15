#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)
require 'geo_convertor'

class TileCacheFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  def mtime
    File.mtime(@filename)
  end

  def zxy_vars
    unless %r{\/(\d+)/(\d+)/(\d+)\.json\z} =~ @filename
      raise "No valid bbox for cachefile: #{@filename.inspect}"
    end
    [$1.to_i, $2.to_i, $3.to_i]
  end

  def bbox
    GeoConvertor.tile2bounding_box(*zxy_vars)
  end

  def delete
    File.delete(@filename)
  end

  def url
    Rails.application.routes.url_helpers.public_tiles_path(*zxy_vars)
  end
end

def bbox_yonger_than(bbox, datetime)
  Shape
    .in_bounding_box(bbox)
    .joins(events: :document)
    .where(
      '(events.updated_at > ?) OR (documents.updated_at > ?)',
      datetime,
      datetime
    )
    .exists?
end

cache_root = File.join(EventsController.page_cache_directory, 'public', 'tiles')

Dir.glob("#{cache_root}/**/*.json").each do |cache_file|
  cache = TileCacheFile.new(cache_file)
  Rails.logger.info "Testuji cache_file: #{cache.filename.inspect}"
  if bbox_yonger_than(cache.bbox, cache.mtime)
    Rails.logger.info "Mazu cache #{cache.filename.inspect} pro: #{cache.url}"
    cache.delete
  end
end
