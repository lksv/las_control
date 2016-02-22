# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

LocalAdministrationModel.setup

# Do not need to eager_load all, I just need
# app/models/local_administration_unit.rb
# but putting all - its better for debugging purposes
Rails.application.eager_load!
