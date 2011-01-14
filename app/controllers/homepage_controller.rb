class HomepageController < ApplicationController
  def show
    @top_rated = TopItem.highest_rated(3)
    @most_visited_conversations = Conversation.get_top_visited(3)
    
    @conversations = Conversation.order("created_at DESC").paginate(:page => params[:page], :per_page => 12)
    
    @main_article = Article.homepage_main_article.first
    @sub_articles = Article.homepage_sub_articles.limit(3)
    @regions = Region.all

    @recent_items = [] #TopItem.with_items_and_associations.newest_items(3).collect(&:item)
  end
end
