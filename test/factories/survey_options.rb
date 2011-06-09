Factory.define :survey_option do |f|
  f.survey_id 1
  f.sequence(:position) {|n| n }
  f.sequence(:title) {|n| "my Title #{n}"}
  f.sequence(:description) {|n| "my Description #{n}" }
end
