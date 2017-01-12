#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

DOCUMENT_CACHE_ROOT = File.join(
  DocumentsController.page_cache_directory,
  'documents'
)
DOCUMENT_CACHE = ->(document) { "#{DOCUMENT_CACHE_ROOT}/%s/*" % document.id }

SHAPE_CACHE_ROOT = File.join(
  DocumentsController.page_cache_directory,
  'shapes'
)
SHAPE_CACHE = ->(shape) { "#{SHAPE_CACHE_ROOT}/%s/*" % shape.id }

ADDRESS_BLOCK_CACHE_ROOT = File.join(
  DocumentsController.page_cache_directory,
  'documents'
)
ADDRESS_BLOCK_CACHE = ->(addr_block) { "#{ADDRESS_BLOCK_CACHE_ROOT}/%s/address_blocks/%s.*" % [addr_block.source.id, addr_block.id] }


def document_modified_after(time)
  #Document
  #  .joins(:address_blocks, events: :shape)
  #  .where('(documents.updated_at > ?) OR ' \
  #         '(address_blocks.updated_at > ?) OR ' \
  #         '(events.updated_at > ?) OR ' \
  #         time, time, time)


  events_modified_after = Document.select(:id).joins(:events).where('events.updated_at > ?', time)
  address_blocks_modified_after = Document.select(:id).joins(:address_blocks).where('address_blocks.updated_at > ?', time)
  Document.where(
    'id IN (?) OR id IN (?) or updated_at > ?',
    events_modified_after,
    address_blocks_modified_after,
    time
  )
end

def shape_modified_after(time)
  events_modified_after = Shape.select(:id).joins(:events).where('events.updated_at > ?', time)
  documents_modified_after = Shape.select(:id).joins(events: :document).where('documents.updated_at > ?', time)

  Shape.where(
    'id IN (?) OR id IN (?)',
    events_modified_after,
    documents_modified_after
  )
end

def address_block_after(time)
  events_modified_after = AddressBlock.select(:id).joins(:events).where('events.updated_at > ?', time)
  documents_modified_after = AddressBlock.select(:id).joins(:document).where('documents.updated_at > ?', time)
  AddressBlock.where(
    'id IN (?) OR id IN (?) OR updated_at > ?',
    events_modified_after,
    documents_modified_after,
    time
  )
end


def clear_expired(scope, cache_format)
  scope.each do |item|
    cache_files = Dir.glob(cache_format.call(item))
    expired_files = cache_files.find_all do |cache_file|
      # puts "#{item.id}: #{File.ctime(cache_file)} <= #{item.updated_at}"
      File.ctime(cache_file) <= item.updated_at
    end
    next if expired_files.empty?
    puts "Deleting expired files: #{expired_files.inspect}"
    FileUtils.rm_rf expired_files  # In case document was changed, then all sub-pages (document/ID/address_blocks/ are expired)
  end
end

time = 1.day.ago

clear_expired(document_modified_after(time), DOCUMENT_CACHE)
clear_expired(address_block_after(time), ADDRESS_BLOCK_CACHE)
clear_expired(shape_modified_after(time), SHAPE_CACHE)
