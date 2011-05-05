//Surveys
jQuery(function ($) {
  $(document).ready(function() {
  
    $('.survey-option').click(function(){
      $(this).find('.description').show();
    });
    $('.survey-options .sortable').sortable({ 
      connectWith: '.selected-survey-options .sortable',
      cursor: 'crosshair'
    });
    $('.selected-survey-options .sortable').sortable({ 
      connectWith: '.survey-options .sortable',
    });
    
  });
});
