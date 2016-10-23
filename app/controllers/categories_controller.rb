class CategoriesController < ApplicationController
  skip_authorization_check only: [:options]

  def options
    res = Document.tags_cloud.map(&:first).map do |tag|
      {
        text: Category.new(tag).name,
        id: tag
      }
    end
    res = res.find_all { |c| c[:text] =~ /\b#{Regexp.escape(params[:query].to_s)}/ }
    render json: res
  end
end
