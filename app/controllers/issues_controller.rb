class IssuesController < ApplicationController
  before_filter :verify_admin, :only=>[:new, :create, :edit, :update, :destroy]
  before_filter :authenticate_person!, :only => [:create_contribution]

  # GET /issues
  # GET /issues.xml
  def index
    @search = Issue.sort(params[:sort]).search(params[:search])
    @issues = @search.paginate(:page => params[:page], :per_page => 20)
    
    @regions = Region.all
    @main_article = Article.issue_main_article.first
    @sub_articles = Article.issue_sub_articles.limit(3)
    @recent_items = TopItem.newest_items(3).for(:issue).collect(&:item)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @issues }
      format.json  { render :json => @issues }
    end
  end

  # GET /issues/1
  # GET /issues/1.xml
  def show
    @issue = Issue.find(params[:id])
    @latest_conversations = @issue.conversations.latest_updated.limit(3)
    all_conversations_on_issue = @issue.conversations.latest_updated
    @conversations = all_conversations_on_issue.paginate(:page => params[:page], :per_page => 6)
    @people = @issue.participants
    @written_contributions = @issue.written_contributions.most_recent
    @conversation_comments = @issue.conversation_comments.most_recent
    @suggested_actions = @issue.suggested_actions.most_recent
    @media_contributions = @issue.media_contributions.most_recent
    
    @issue.visit!((current_person.nil? ? nil : current_person.id))
    @recent_items = TopItem.newest_items(3).for(:issue => @issue.id).collect(&:item)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @issue }
      format.json  { render :json => @issue }
    end
  end

  # GET /issues/new
  # GET /issues/new.xml
  def new
    @issue = Issue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @issue }
    end
  end

  # GET /issues/1/edit
  def edit
    @issue = Issue.find(params[:id])
  end

  # POST /issues
  # POST /issues.xml
  def create
    @issue = Issue.new(params[:issue])

    respond_to do |format|
      if @issue.save
        format.html { redirect_to(@issue, :notice => 'Issue was successfully created.') }
        format.xml  { render :xml => @issue, :status => :created, :location => @issue }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create_contribution
    @issue = Issue.find(params[:id])
    contribution_params = params[:contribution].merge(:issue_id => @issue.id)
    @contribution = Contribution.
      create_confirmed_node_level_contribution(contribution_params, current_person)

    respond_to do |format|
      if @contribution.save
        format.html { render :json => @contribution, :status => :created }
      else
        format.html { render :json => {:errors => @contribution.errors.full_messages }, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /issues/1
  # PUT /issues/1.xml
  def update
    @issue = Issue.find(params[:id])

    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        format.html { redirect_to(@issue, :notice => 'Issue was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @issue.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.xml
  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy

    respond_to do |format|
      format.html { redirect_to(issues_url) }
      format.xml  { head :ok }
    end
  end
end
