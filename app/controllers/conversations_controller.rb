class ConversationsController < ApplicationController
  # GET /conversations
  # GET /conversations.xml
  def index
    @search = Conversation.search(params[:search])
    @conversations = @search.all   # or @search.relation to lazy load in view

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @conversations }
    end
  end

  # GET /conversations/1
  # GET /conversations/1.xml
  def show
    @conversation = Conversation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @conversation }
    end
  end

  # GET /conversations/new
  # GET /conversations/new.xml
  def new
    @conversation = Conversation.new

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
    @conversation = Conversation.new(params[:conversation])
    @conversation.issues = Issue.find(params[:issue_ids]) unless params[:issue_ids].blank?
    @conversation.started_at = Time.now

    respond_to do |format|
      if @conversation.save
        format.html { redirect_to(@conversation, :notice => 'Conversation was successfully created.') }
        format.xml  { render :xml => @conversation, :status => :created, :location => @conversation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @conversation.errors, :status => :unprocessable_entity }
      end
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
end
