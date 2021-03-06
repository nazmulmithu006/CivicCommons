class VotePage < PageObject
  OPTIONS_LOCATOR = '.survey-options .sortable .survey-option'
  SELECTED_OPTIONS_LOCATOR = '.selected-survey-options .sortable .survey-option'
  VOTEBOX_LOCATOR = '.selected-survey-options .sortable'
  VOTE_RESULTS = 'ul.survey_results'
  BALLOT_FORM_DISABLED = '.selected-survey-options.disabled'
  SUBMIT_BUTTON_TITLE = 'Cast Ballot'


  def has_vote_dialog?
    find('a', :content => 'Yes').visible?
  end

  def visit_a_vote(vote)
    visit independent_vote_path(vote)
  end

  def independent_vote_path(vote)
    "/votes/#{vote.id}"
  end

  def visit_vote_on_an_issue(issue)
    visit "/issues/#{issue.id}/vote"
  end

  def drag_from_to(from_locator, to_locator)
    script ="
      //taken from surveys.js 
      var $from = $('.survey-options .sortable .survey-option').first().remove();
      var $to = $('.selected-survey-options .sortable').first()
      $to.children('.placeholder').hide();
      $to.append($from);
      updateOptionID($to);
    "
    page.execute_script(script)
  end
  
  def select_one_option
    drag_from_to( OPTIONS_LOCATOR, VOTEBOX_LOCATOR)
  end
  
  def click_submit
    page.click_button SUBMIT_BUTTON_TITLE
    wait_until { has_vote_dialog? }
  end
  
  def available_options(options)
    count = options.delete(:count)
    page.find OPTIONS_LOCATOR
  end
  
  def selected_options
    page.find SELECTED_OPTIONS_LOCATOR 
  end

end
