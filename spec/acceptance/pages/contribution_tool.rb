class ContributionTool < PageObject

  def tool
    @page.find('div#contrib')
  end

  def visible?

   @page.find('.contrib_tool_container').visible?
  end

  def post_to_link
    @page.find_link('post_to_conversation')
  end
  def add_url url
    add_url_link.click
    fill_in_url_field url
  end
  def add_file file_path
    add_file_link.click
    select_file(file_path)
  end
  def cancel_adding_url
    @page.find('a.close').click
  end
  def respond_to_link(contribution)
    if contribution.is_a? Contribution
      id = contribution.id
    else
      id = contribution.to_i
    end
    @page.find_link("respond-to-#{id}")
  end

  def content_field
    @page.find('textarea#contribution_content')
  end

  def wysiwyg_editor
    @page.find('span.mceEditor')
  end

  def add_url_link
    @page.find_link('contribution-add-link')
  end

  def url_field
    @page.find_field('contribution_url')
  end

  def add_file_link
    @page.find_link('contribution-add-file')
  end

  def file_field
    @page.find_field('contribution_attachment')
  end

  def submit_button
    @page.find('input.submit.contribution-tool')
  end

  def cancel_link
    @page.find_link('cancel-contribution')
  end

  def error
    @page.find('div#error_explanation')
  end

  def has_error?
    !! self.error
  end

  def fill_in_content_field(value)
    begin
      @page.execute_script("$('#contribution_content').tinymce().setContent('#{value}')")
    rescue Capybara::NotSupportedByDriverError
      @page.fill_in('contribution_content', :with => value)
    end
  end

  def fill_in_url_field(value)
    @page.fill_in('contribution_url', :with => value)
  end

  def select_file(file_path)
    @page.attach_file('contribution_attachment', File.expand_path(file_path))
  end
  def within_container? selector
    within selector do
      page.has_selector? 'li.tinymce-container'
    end
  end
end
