class CCML::Tag::VoteTag < CCML::Tag::SingleTag
  
  #{ccml:vote id='1'}  
  #{ccml:vote limit='10'}  
  
  def index
    if @opts.has_key?(:id)
      votes = [Vote.find(@opts[:id])]
    else
      limit = @opts[:limit] || 10
      votes = Vote.all(:limit => limit.to_i)
    end
    
    return @renderer.render :partial => '/surveys/vote_band', :locals => {:votes => votes}
    
  rescue ActiveRecord::RecordNotFound => e
    return nil
  end
  
  
end