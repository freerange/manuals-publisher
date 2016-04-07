require 'ostruct'

class PaginationPresenter < SimpleDelegator
  attr_reader :current_page, :total_pages, :total_count, :limit_value

  def initialize(api_response, per_page)
    # actually delegate to the API response's `results` array
    super(present_results(api_response.results))

    @current_page = api_response.current_page
    @total_pages = api_response.pages
    @total_count = api_response.total
    @limit_value = per_page
  end

private
  def present_results(results)
    results.map { |entry| OpenStruct.new(entry) }
  end
end
