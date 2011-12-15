module CivicCommonsDriver
  module Database
    def database
      Database
    end

    def self.has_any?(type)
      !Topic.count.zero?
    end

    def self.has_any_topics?
      !Topic.count.zero?
    end

    def self.first_topic
      Topic.first
    end

    def self.latest_blog_post
      ContentItem.blog_post.last
    end

    def self.latest_radio_show
      ContentItem.radio_show.last
    end

    def self.latest_topic
      topic = Topic.last
      topic.instance_eval do
        def removed_from? page
          page.has_no_css? container
        end
        def container
          "[data-topic-id='#{self.id}']"
        end
      end
      topic
    end

    def self.create_conversation attributes={}
      Factory.create :conversation, attributes
    end

    def self.create_topic(attributes={})
      Factory.create :topic, attributes
    end

    def self.has_a_topic_without_issues
      create_topic({:issues => []})
    end

    def self.create_issue(attributes= {})
      Factory.create :issue, attributes
    end

    def self.create_blog_post(attributes = {})
      Factory.create :blog_post, attributes
    end

    def self.create_radio_show(attributes = {})
      Factory.create :radio_show, attributes
    end

    class << self
      alias :has_a_blog_post :create_blog_post
      alias :has_a_radio_show :create_radio_show
      alias :has_a_conversation :create_conversation
      alias :has_an_issue :create_issue
      alias :has_a_topic :create_topic
    end

    def self.latest_issue
      IssuePresenter.new Issue.last
    end

    def self.issues
      Issue.all.map! { |i| IssuePresenter.new i }
    end

    def self.topics
      Topic.all
    end

    def self.has_any_issues?
      !Issue.all.empty?
    end

    def self.find_user(user)
      Person.find(user.id)
    end

    def self.conversation
      Conversation.last
    end

    def self.blog_post
      ContentItem.where(:content_type => 'BlogPost').last
    end

    def self.radio_show
      ContentItem.where(:content_type => 'RadioShow').last
    end
  end
end
