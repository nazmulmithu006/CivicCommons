class CCML::Tag::IssueTag < CCML::Tag::TagPair

  # 'index' method with no opts grabs issue id from segment_1
  #
  # {ccml:issue}
  # <h1>Managed Issue: '{name}'</h1>
  # <ul>
  #   <li>ID: {id}</li>
  #   <li>Name: {name}</li>
  #   <li>Created: {created_at format='%A, %B %d at %I:%M%S %p'}</li>
  #   <li>Updated: {updated_at format='%A, %B %d at %I:%M%S %p'}</li>
  #   <li>Total Visits: {total_visits}</li>
  #   <li>Recent Visits: {recent_visits}</li>
  #   <li>Total Rating: {total_rating}</li>
  #   <li>Recent Rating: {recent_rating}</li>
  #   <li>Last Visit: {last_visit_date format='%A, %B %d at %I:%M%S %p'}</li>
  #   <li>Last Rating: {last_rating_date format='%A, %B %d at %I:%M%S %p'}</li>
  #   <li>Zip Code: {zip_code}</li>
  #   <li>Image File Name: {image_file_name}</li>
  #   <li>Image Content Type: {image_content_type}</li>
  #   <li>Image File Size: {image_file_size}</li>
  #   <li>URL: {url}</li>
  #   <li>URL Title: {url_title}</li>
  #   <li>Cached Slug: {cached_slug}</li>
  #   <li>Type: {type}</li>
  #   <li>Conversations: {conversations.size}</li>
  #   <li>Participants: {participants.size}</li>
  #   <li>Summary: {summary}</li>
  # </ul>
  # {/ccml:issue}
  #
  # {ccml:issue id='id or cached-slug or segment'}
  # {/ccml:issue}
  def index
    @opts[:id] = @segments[1] unless @opts.has_key?(:id)
    @issue = Issue.includes(:conversations, :participants).find(@opts[:id])
    return process_tag_body(@issue)
  rescue ActiveRecord::RecordNotFound => e
    return nil
  end

  # 'pages' method with no opts grabs issue id from segment_1
  #
  # {ccml:issue:pages id='<id or cached-slug or segment>'}
  # <h2>Issue Page: '{name}'</h2>
  # <ul>
  #   <li>ID: {id}</li>
  #   <li>Name: {name}</li>
  #   <li>Issue: {issue.name}</li>
  #   <li>Author Name: {author.name}</li>
  #   <li>Author Email: {author.email}</li>
  #   <li>Created: {created_at format='%A, %B %d at %I:%M%S %p'}</li>
  #   <li>Updated: {updated_at format='%A, %B %d at %I:%M%S %p'}</li>
  #   <li>Cached Slug: {cached_slug}</li>
  # </ul>
  # {/ccml:issue:pages}
  def pages
    @opts[:id] = @segments[1] unless @opts.has_key?(:id)
    @issue = ManagedIssue.find(@opts[:id])
    return process_tag_body(@issue.pages)
  rescue ActiveRecord::RecordNotFound => e
    return nil
  end

  # 'conversations' method with no opts grabs issue id from segment_1
  #
  # <h1>Conversations</h1>
  # {ccml:issue:conversations}
  # <h2>Conversation: '{title}'</h2>
  # <ul>
  #   <li>ID: {id}</li>
  #   <li>Started: {started_at format='%A, %B %d at %I:%M%S %p'} </li>
  #   <li>Finished: {finished_at format='%A, %B %d at %I:%M%S %p'} </li>
  #   <li>Created: {created_at format='%A, %B %d at %I:%M%S %p'} </li>
  #   <li>Updated: {updated_at format='%A, %B %d at %I:%M%S %p'} </li>
  #   <li>Title: {title} </li>
  #   <li>Image: {image} </li>
  #   <li>Image File Name: {image_file_name} </li>
  #   <li>Image Content Type: {image_content_type} </li>
  #   <li>Image File Size: {image_file_size} </li>
  #   <li>Zip Code: {zip_code} </li>
  #   <li>Total Visits: {total_visits} </li>
  #   <li>Recent Visits: {recent_visits} </li>
  #   <li>Last Visit Date: {last_visit_date} </li>
  #   <li>Total Rating: {total_rating} </li>
  #   <li>Recent Rating: {recent_rating} </li>
  #   <li>Last Rating Date: {last_rating_date} </li>
  #   <li>Video URL: {video_url} </li>
  #   <li>Audio Clip File Name: {audio_clip_file_name} </li>
  #   <li>Audio Clip Content Type: {audio_clip_content_type} </li>
  #   <li>Audio Clip File Size: {audio_clip_file_size} </li>
  #   <li>Audio Clip Updated: {audio_clip_updated_at format='%A, %B %d at %I:%M%S %p'} </li>
  #   {if person}<li>Leader Name: {person.name} </li>{/if}
  #   {if person}<li>Leader Email: {person.email} </li>{/if}
  #   <li>Summary: {summary} </li>
  # </ul>
  # {/ccml:issue:conversations}
  def conversations
    @opts[:id] = @segments[1] unless @opts.has_key?(:id)
    @issue = Issue.find(@opts[:id])
    return process_tag_body(@issue.conversations)
  rescue ActiveRecord::RecordNotFound => e
    return nil
  end

  def convos
    return conversations
  end

  # 'conversation_band' method with no opts grabs issue id from segment_1
  #
  # {ccml:issue:conversation_band id='<id or cached-slug or segment>'}
  # {ccml:issue:conversation_band id='<id or cached-slug or segment>'}{/ccml:issue:conversation_band}
  def conversation_band
    issue = get_issue
    if issue
      limit = @opts[:limit].to_i
      if limit > 0
        conversations = issue.conversations.slice(0, limit)
      else
        conversations = issue.conversations
      end
      return @renderer.render :partial => '/conversations/conversation_band', :locals => {:conversations => conversations}
    else
      return nil
    end
  end
  
  # 'vote_band' method with no opts grabs issue id from segment_1
  #
  # {ccml:issue:vote_band id='<id or cached-slug or segment>'}
  # {ccml:issue:vote_band id='<id or cached-slug or segment>' limit='2'}{/ccml:issue:conversation_band}
  def vote_band
    issue = get_issue
    if issue
      limit = @opts[:limit].to_i
      if limit > 0
        votes = issue.votes.slice(0, limit)
      else
        votes = issue.votes
      end
      return @renderer.render :partial => '/surveys/vote_band', :locals => {:votes => votes}
    else
      return nil
    end
  end

  def convo_band
    return conversation_band
  end

  private

  def get_issue
    @opts[:id] = @segments[1] unless @opts.has_key?(:id)
    issue = Issue.find(@opts[:id])
  rescue ActiveRecord::RecordNotFound => e
    issue = nil
  ensure
    return issue
  end

end
