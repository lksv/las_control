class AboutController < ApplicationController
  skip_authorization_check only: [:index, :intro]

  def index
  end

  def intro
  end
end
