class ConversationsController < ApplicationController
  before_filter :verify_admin, :only=>[:new, :create, :edit, :update, :destroy]
  before_filter :require_user, :only=>[:new_node_contribution, :preview_node_contribution, :confirm_node_contribution]

  # GET /conversations
  # GET /conversations.xml
  def index
    @conversations = Conversation.latest_updated.paginate(:page => params[:page], :per_page => 12)

    @main_article = Article.conversation_main_article.first
    @sub_articles = Article.conversation_sub_articles.limit(3)
    @regions = Region.all
    @recent_items = [] #TopItem.newest_items(3).for(:conversation).collect(&:item)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @conversations }
    end
  end

  # GET /conversations/1
  # GET /conversations/1.xml
  def show
    @conversation = Conversation.includes(:guides, :issues).find(params[:id])
    @conversation.visit!((current_person.nil? ? nil : current_person.id))
    @top_level_contributions = TopLevelContribution.where(:conversation_id => @conversation.id).includes([:person]).order('created_at ASC').with_user_rating(current_person)
    # grab all direct contributions to conversation that aren't TLC
    @conversation_contributions = Contribution.not_top_level.confirmed.without_parent.where(:conversation_id => @conversation.id).includes([:person]).order('created_at ASC').with_user_rating(current_person)
    #@contributions = Contribution.confirmed.with_user_rating(current_person).descendants_of(@conversation_contributions).includes([:person])

    @top_level_contribution = Contribution.new # for conversation comment form
    @tlc_participants = @top_level_contributions.collect{ |tlc| tlc.owner }

    @latest_contribution = @conversation.confirmed_contributions.most_recent.first

    @recent_items = [] #TopItem.newest_items(5).for(:conversation => @conversation.id).collect(&:item)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @conversation }
    end
  end

  def dialog
    @conversation = Conversation.includes(:guides, :issues).find(params[:id])
    @conversation.visit!((current_person.nil? ? nil : current_person.id))
    @conversation_contributions = Contribution.confirmed.not_top_level.without_parent.with_user_rating(current_person).where(:conversation_id => @conversation.id).includes([:person]).order('created_at ASC')
    @contributions = Contribution.confirmed.with_user_rating(current_person).descendants_of(@conversation_contributions).includes([:person])

    @contribution = Contribution.new # for conversation comment form

    @latest_contribution = @conversation.confirmed_contributions.most_recent.first

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @conversation }
    end
  end

  def node_conversation
    @contribution = Contribution.find(params[:id])
    @contributions = @contribution.children.confirmed.includes(:person)
    @contributions = @contributions.with_user_rating(current_person) if current_person
    @contribution.visit!((current_person.nil? ? nil : current_person.id))

    respond_to do |format|
      format.js { render :partial => "conversations/node_conversation", :layout => false}
      format.html { render :partial => "conversations/node_conversation", :layout => false}
    end
  end

  def node_permalink
    contribution = Contribution.with_user_rating(current_person).find(params[:id])
    @contributions = contribution.self_and_ancestors.with_user_rating(current_person)
    @top_level_contribution = @contributions.root
    contribution.visit!((current_person.nil? ? nil : current_person.id))

    respond_to do |format|
      format.js
    end
  end

  def edit_node_contribution
    @contribution = Contribution.find(params[:contribution_id])
    respond_to do |format|
      format.js{ render(:partial => 'conversations/new_contribution_form', :locals => {:div_id => params[:div_id], :type => @contribution.type.underscore.to_sym}, :layout => false) }
    end
  end

  def update_node_contribution
    @contribution = Contribution.with_user_rating(current_person).find(params[:contribution][:id])
    respond_to do |format|
      if @contribution.update_attributes_by_user(params[:contribution], current_person)
        format.js{ render(:partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution, :div_id => params[:div_id]}, :layout => false, :status => :ok) }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new_node_contribution
    @contribution = Contribution.find_or_new_unconfirmed(params, current_person)
    respond_to do |format|
      format.js { render(:partial => "conversations/tabbed_post_box", :locals => {:div_id => params[:div_id], :layout => false}) }
      format.html { render(:partial => "conversations/tabbed_post_box", :locals => {:div_id => params[:div_id], :layout => false}) }
    end
  end

  def preview_node_contribution
    @contribution = Contribution.update_or_create_node_level_contribution(params[:contribution], current_person)
    respond_to do |format|
      if @contribution.valid?
        format.js { render(:partial => "conversations/new_contribution_preview", :locals => {:div_id => params[:div_id], :layout => false}) }
        format.html { render(:partial => "conversations/new_contribution_preview", :locals => {:div_id => params[:div_id], :layout => 'application'}) }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
        format.html { render :text => @contribution.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  #TODO: consider moving this to its own controller?
  def confirm_node_contribution
    @contribution = Contribution.unconfirmed.find_by_id_and_owner(params[:contribution][:id], current_person.id)

    respond_to do |format|
      if @contribution.confirm!
        format.js   { render :partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution}, :status => (params[:preview] ? :accepted : :created) }
        format.html   { render :partial => "conversations/contributions/threaded_contribution_template", :locals => {:contribution => @contribution}, :status => (params[:preview] ? :accepted : :created) }
        format.xml  { render :xml => @contribution, :status => :created, :location => @contribution }
      else
        format.js   { render :json => @contribution.errors, :status => :unprocessable_entity }
        format.html { render :text => @contribution.errors, :status => :unprocessable_entity }
        format.xml  { render :xml => @contribution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /conversations/new
  # GET /conversations/new.xml
  def new
    @conversation = Conversation.new
    @presenter = IngestPresenter.new(@conversation)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @conversation }
    end
  end

  # GET /conversations/1/edit
  def edit
    @conversation = Conversation.find(params[:id])
  end

  # POST /conversations
  # POST /conversations.xml
  def create
    ActiveRecord::Base.transaction do
      @conversation = Conversation.new(params[:conversation])
      @conversation = Conversation.new(params[:conversation])
      #TODO: Fix this conversation issues creation since old conversation.issues= method has been destroyed
      #NOTE: Issues were previously defined as Conversation has_many Issues, but this is wrong, should be habtm
      @conversation.issues = Issue.find(params[:issue_ids]) unless params[:issue_ids].blank?
      @conversation.started_at = Time.now
      @presenter = IngestPresenter.new(@conversation, params[:file])

      @conversation.save!
      @presenter.save!
      respond_to do |format|
        format.html { redirect_to(@conversation, :notice => 'Conversation was successfully created.') }
        format.xml  { render :xml => @conversation, :status => :created, :location => @conversation }
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { render :action => "new" }
      format.xml  { render :xml => @conversation.errors + @presenter.errors, :status => :unprocessable_entity }
    end
  end
  # PUT /conversations/1
  # PUT /conversations/1.xml
  def update
    @conversation = Conversation.find(params[:id])

    respond_to do |format|
      if @conversation.update_attributes(params[:conversation])
        format.html { redirect_to(@conversation, :notice => 'Conversation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @conversation.errors, :status => :unprocessable_entity }
      end
    end
  end

  def rate_contribution
    @contribution = Contribution.find(params[:contribution][:id])
    rating = params[:contribution][:rating]

    respond_to do |format|
      if @contribution.rate!(rating.to_i, current_person)
        format.js { render(:partial => 'conversations/contributions/rating', :locals => {:contribution => @contribution}, :layout => false, :status => :created) }
      end
        format.js { render :json => @contribution.errors[:rating].first, :status => :unprocessable_entity }
    end
  end

  # DELETE /conversations/1
  # DELETE /conversations/1.xml
  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.destroy

    respond_to do |format|
      format.html { redirect_to(conversations_url) }
      format.xml  { head :ok }
    end
  end


  # Kludge to convert US date-time (mm/dd/yyyy hh:mm am) to an
  # ISO-like date-time (yyyy-mm-ddThh:mm:ss).
  # There is probably a better way to do this. Please refactor.
  private
  def convert_us_date_to_iso(input)
    hour = input[11,2].to_i
    if (hour == 12)
      hour = 0
    end
    if (input[17,2] == "pm")
      hour += 12
    end
    hour = sprintf("%02d",hour)
    input[6,4]+"-"+input[0,2]+"-"+input[3,2]+"T"+hour+":"+input[14,2]+":00"
  end
end
