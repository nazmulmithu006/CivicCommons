class SearchController < ApplicationController
  def results

    search_service = SearchService.new

    if params[:filter] and not determine_model_class(params[:filter]).nil?
      @models_to_search = determine_model_class(params[:filter])
    else
      @models_to_search = [Conversation, Issue, Person, Contribution, ContentItem, ManagedIssuePage]
    end

    if params[:q] == ''
      flash[:error] = 'You did not search for anything.  Please try again.'
      @results = []
    else
      if(params.key?(:filter))
        @results = search_service.fetch_filtered_results(params[:q], params[:filter], @models_to_search).paginate(page: params[:page], per_page: 10)
      else
        @results = search_service.fetch_results(params[:q], @models_to_search).paginate(page: params[:page], per_page: 10)
      end
    end

  end
  
  def metro_region_city
    @results = MetroRegion.search{fulltext(params[:term])}.results
    @metro_regions = @results.collect{|region| {:id => region.id, :label => region.city_display_name} }
    
    render :json => @metro_regions
  end

  private
  def determine_model_class(model_string)
    case model_string
    when "contributions"
      return Contribution
    when "conversations"
      return Conversation
    when "community"
      return Person
    when "issues"
      return Issue
    when "blogs"
      return ContentItem
    when "radioshows"
      return ContentItem
    when "projects"
      return [Issue, ManagedIssuePage]
    end
  end
end
