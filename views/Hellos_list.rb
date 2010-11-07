# ~/megauni/templates/en-us/html/Hellos_list.rb
# ~/megauni/templates/en-us/css/Hellos_list.sass
# ~/megauni/controls/Hellos.rb

class Hellos_list < Base_View
  
  alias_method :usernames, :current_member_usernames

  def javascripts
    default_javascripts
  end

  def title
    "#{Uni_App::SITE_TITLE}"
  end

  def meta_description
    Uni_App::SITE_TAG_LINE
  end

  def meta_keywords
    'lots of clubs'
  end

  def site_tag_line
    meta_description
  end
  
  def messages_public 
    compile_and_cache( 'messages.public', app.the.messages_public )
  end
  
  def clubs
    return []
    @cache_clubs ||= begin
                        old_clubs + app.the.clubs.map { |r| 
                          r[:href] = "/uni/#{r['filename']}/"
                          r
                        }  
                      end
  end 

  def city_clubs
    return []
    @cache_clubs_cities ||= compile_clubs( Club.by_club_model('city') )
  end

  def beauty_clubs
    return []
    @cache_clubs_beauty ||= compile_clubs( Club.by_club_model(['healty', 'beauty']) )
  end

  def political_clubs
    return []
    @cache_clubs_evil ||= compile_clubs(Club.by_club_model(['economics', 'history']))
  end

  def joy_clubs
    return []
    @cache_clubs_joy ||= compile_clubs(Club.by_club_model(['joy', 'fun']))
  end

  %w{ city joy }.each { |club|
    eval(%~
      def #{club}_clubs?     
        @cache_not_empty_#{club} ||= begin
          arr = #{club}_clubs
          arr && !arr.empty?
         end
      end
    ~)
  }

  def political_beauty?
    @cache_not_empty_pb ||= begin
                                 !(beauty_clubs.empty? && political_clubs.empty?)
                               end
  end

  def random_clubs
    return []
    @cache_random_clubs ||= begin
                                 filenames = %w{ hearts predictions vitamins }
                                 doc = Club.by_filename(filenames[rand(filenames.size)])
                                 club = if doc
                                   club = doc.data.as_hash
                                   club['messages'] = compile_messages(Message.latest_by_club_id club['_id'])
                                   club
                                 end
                                 compile_clubs([club])
                               end
  end
  
end # === Hello_Bunny_GET_list
