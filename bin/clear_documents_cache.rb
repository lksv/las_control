#!/usr/bin/env ruby

require File.expand_path('../../config/environment', __FILE__)

DOCUMENT_CACHE_ROOT = File.join(
  DocumentsController.page_cache_directory,
  'public', 'documents'
)
DOCUMENT_CACHE = "#{DOCUMENT_CACHE_ROOT}/%s.*"

SHAPE_CACHE_ROOT = File.join(
  DocumentsController.page_cache_directory,
  'public', 'shapes'
)
SHAPE_CACHE = "#{SHAPE_CACHE_ROOT}/%s.*"

ADDRESS_BLOCK_CACHE_ROOT = File.join(
  DocumentsController.page_cache_directory,
  'public', 'address_blocks'
)
ADDRESS_BLOCK_CACHE = "#{ADDRESS_BLOCK_CACHE_ROOT}/%s.*"


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
  documents_modified_after = Shape.select(:id).joins(events: :document).where('document.updated_at > ?', time)

  Shape.where(
    'id IN (?) OR id IN (?) OR updated_at > ?',
    events_modified_after,
    documents_modified_after,
    time
  )
end

def address_block_after(time)
  events_modified_after = AddressBlock.select(:id).joins(:events).where('events.updated_at > ?', time)
  documents_modified_after = AddressBlock.select(:id).joins(:document).where('document.updated_at > ?', time)
  AddressBlock.where(
    'id IN (?) OR id IN (?) OR updated_at > ?',
    events_modified_after,
    documents_modified_after,
    time
  )
end


def clear_expired(scope, cache_format)
  scope.each do |item|
    expired_files = Dir.glob(SHAPE_CACHE % item.id)
    next if expired_files.empty?
    puts "Deleting expired files: #{expired_files.inspect}"
    FileUtils.rm expired_files
  end
end

time = 1.day.ago

clear_expired(address_block_after(time), ADDRESS_BLOCK_CACHE)
clear_expired(shape_modified_after(time), SHAPE_CACHE)
clear_expired(document_modified_after(time), DOCUMENT_CACHE)
