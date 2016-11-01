class CategoriesController < ApplicationController
  skip_authorization_check only: [:options, :index]

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

  def index
    categories_with_key = Category::CATEGORY_MAPPING.each_with_object([]) do |(key,value), result|
      value[:key] = key
      result << value
    end

    render json: categories_with_key
  end
end
