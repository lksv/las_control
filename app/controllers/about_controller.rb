class AboutController < ApplicationController
  skip_authorization_check only: [:index, :intro, :terms]

  def index
  end

  def intro
  end
end
