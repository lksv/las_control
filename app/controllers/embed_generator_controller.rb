class EmbedGeneratorController < ApplicationController
  skip_authorization_check only: [:index]

  def index
    respond_to do |format|
      format.html { render :index }
    end
  end
end
