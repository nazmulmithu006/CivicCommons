Factory.define :vote do |f|
  f.surveyable_id 1
  f.surveyable_type 'Issue'
  f.title 'This is a title'
  f.description  'Description here'
  f.options []
  f.max_selected_options 3
end