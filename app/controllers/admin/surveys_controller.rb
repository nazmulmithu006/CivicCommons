class Admin::SurveysController < Admin::DashboardController
  # GET /admin/surveys
  # GET /admin/surveys.xml
  def index
    @surveys = Survey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @surveys }
    end
  end

  # GET /admin/surveys/1
  # GET /admin/surveys/1.xml
  def show
    @survey = Survey.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @survey }
    end
  end

  # GET /admin/surveys/new
  # GET /admin/surveys/new.xml
  def new
    @survey = Survey.new
    3.times do
      @survey.options.build
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey }
    end
  end

  # GET /admin/surveys/1/edit
  def edit
    @survey = Survey.find(params[:id])
    @survey.options.build
    @survey_options = @survey.options
  end

  # POST /admin/surveys
  # POST /admin/surveys.xml
  def create
    @survey = Survey.new(params[:survey])

    respond_to do |format|
      if @survey.save
        format.html { redirect_to(admin_survey_url(@survey), :notice => 'Survey was successfully created.') }
        format.xml  { render :xml => @survey, :status => :created, :location => @survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/surveys/1
  # PUT /admin/surveys/1.xml
  def update
    @survey = Survey.find(params[:id])

    respond_to do |format|
      if @survey.update_attributes(params[:survey])
        format.html { redirect_to(admin_survey_url(@survey), :notice => 'Survey was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/surveys/1
  # DELETE /admin/surveys/1.xml
  def destroy
    @survey = Survey.find(params[:id])
    @survey.destroy

    respond_to do |format|
      format.html { redirect_to(admin_surveys_url) }
      format.xml  { head :ok }
    end
  end
end
