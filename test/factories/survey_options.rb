Factory.define :survey_option do |f|
  f.survey_id 1
  f.sequence(:position) {|n| n }
end
