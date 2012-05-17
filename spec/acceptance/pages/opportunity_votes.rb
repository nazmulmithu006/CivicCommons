module CivicCommonsDriver
  module Pages
    class OportunityVotes
      class New
        SHORT_NAME = :new_opportunity_vote
        include Page
        
        has_link :add_option, 'Add another option', :new_opportunity_vote
        has_link :delete_option, 'Delete option', :new_opportunity_vote
        has_button :publish_invalid_vote, 'Publish', :new_opportunity_vote
        
        has_button :publish, 'Publish', :opportunity_vote
        
        def drag_from_to(from_position, to_position)
          # element = find_field(".survey-option:nth-child(#{order.to_i})")
          script ="
            var $from =$('.survey-option:nth-child(#{from_position.to_i})').first();
            var $to = $('.survey-option:nth-child(#{to_position.to_i})').first();
            
            //this is to avoid glitch of when ckeditor is updated, it clears it, automatically.
            var ck_from_id = $('textarea.option-description', $from).attr('id');
            CKEDITOR.instances[ck_from_id].updateElement();
            
            $to.after($from);
            init_opportunity_vote_option($from);
          "
          page.execute_script(script)
        end
        alias :reorder_option :drag_from_to
        
        def find_title_field_for(position)
          find(:xpath, "//*[contains(@class,'survey-option')][#{position.to_i}]//input[contains(@class,'option-title')]")
        end

        def fill_in_title_field_for(position, value)
          element = find_title_field_for(position)
          fill_in element[:id], :with => value
        end
        
        def find_description_field_for(position)
          find(:xpath, "//*[contains(@class,'survey-option')][#{position.to_i}]//textarea[contains(@class,'option-description')]")
        end
        
        def fill_in_wysywig_description_field_for(position, value)
          element = find_description_field_for(position)
          page.execute_script("CKEDITOR.instances['#{element[:id]}'].setData('#{value}');")
        end
        
        def has_error?
          has_content? 'There were errors saving this vote.'
        end
        
        def has_options?(num)
          has_selector? '.survey-option', :count => num
        end
        
      end
      class Show
        SHORT_NAME = :opportunity_vote
        include Page
        
      end
    end
  end
end
