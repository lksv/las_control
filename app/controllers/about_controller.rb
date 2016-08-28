class AboutController < ApplicationController
  skip_authorization_check only: [:index, :intro, :terms, :offers]

  def index
  end

  def intro
  end
end
