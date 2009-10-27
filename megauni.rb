$KCODE = 'UTF8'


# Ramaze::Global.content_type = 'text/html; charset=utf-8'
# Ramaze::Global.accept_charset = 'utf-8'
#header("Cache-Control: no-cache");
#header("Pragma: no-cache");

# ===============================================
# Important Gems
# ===============================================

require 'rubygems'
require 'multibyte'
require 'sinatra'
require File.expand_path('./helpers/kernel')
require Pow('helpers/issue_client')
#require 'rack-flash'

# ===============================================
# Configurations
# ===============================================
use Rack::Session::Pool

# Don't use ":sweep => true" because it
# will only allow you to use flash values once
# per call, not per request. Or it could
# prevent it's use after a redirect.
# use Rack::Flash, :accessorize => [:notice, :success_msg, :error_msg]

configure :test do
  #require Pow('~/.megauni')
end


configure :development do
  #require Pow('~/.megauni')
  require Pow('helpers/css')
  require Pow('actions/try_textile')
  enable :clean_trace
end


configure(:production) do
  # === Error handling.
  #require Pow('helpers/public_500')
  #enable :raise_errors
  #enable :show_exceptions
  #use Rack::Public500
  #DB = Sequel.connect ENV['DATABASE_URL']
end


configure do

# set :session, true # Don't use this because: http://www.gittr.com/index.php/archive/using-alternate-session-stores-with-sinatra/

  set :site_title,        'Mega Uni'
  set :site_tag_line,     "For all your different lives: friends, family, work & romance."
  set :site_keywords,     'to-do lists predictions'
  set :site_domain,       'megaUni.com'
  set :site_help_email,     Proc.new { "helpme@#{site_domain}"  }
  set :site_url,            Proc.new { "http://www.#{site_domain}/" }
  set :site_support_email,  Proc.new { "helpme@#{site_domain}"  }
  set :cache_the_templates, Proc.new { !development? }
  set :views,               Pow('views/skins/jinx')

  # Special sanitization code used throughout the app.
  require Pow!( 'helpers/wash' )

  # === Include models.
  #require Pow('helpers/model_init')

end # === configure


# ===============================================
# Helpers
# ===============================================

helpers {
  def dev_log_it( msg )
      puts(msg) if options.development?
  end

  def redirect(uri, *args)
    if !request.get? && args.detect { |s| s.to_i > 200 && s.to_i < 500 }
      raise ArgumentError,
            "No status code allowed for non-GET requests: #{args.inspect}"
    end
    if request.get? || request.head?
      status 302
    else
      status 303
    end

    #if request.get? && mobile_request?
    #  uri = File.join(uri, 'm/')
    #end
    
    keep_flash

    response['Location'] = uri
    halt(*args)
  end
}


require_these 'helpers/sinatra', %w{
  sanitize_input
  describe_action
  urls_and_ssl
  flasher
  old_apps
  describe_action
  auth_and_auth
  resty
  render_ajax_response
  render_mab
  html_props_for_models
  swiss_clock
  text_to_html
  red_cloth
}



# ===============================================
# Error handling.
# ===============================================

error {

  if !request.fullpath["(null)"]
    IssueClient.create(env, options.environment, env['sinatra.error'] )
  end
  read_if_file('public/500.html') || "Programmer error found. I will look into it."
} # === error


not_found {

  # Add trailing slash and use a  permanent redirect.
  # Why a trailing slash? Many software programs
  # look for files by appending them to the url: /salud/robots.txt
  # Without adding a slash, they will go to: /saludrobots.txt
  if request.get? && !request.xhr? && request.query_string.to_s.strip.empty?

    if request.path_info != '/' &&  # Request is not for homepage.
        request.path_info !~ /\.[a-z0-9]+$/ &&  # Request is not for a file.
          request.path_info[ request.path_info.size - 1 , 1] != '/'  # Request does not end in /
      redirect( request.url + '/' , 301 )
    end

    uri_downcase = request.fullpath.downcase

    if uri_downcase != request.fullpath
      redirect uri_downcase
    end

    %w{ mobi mobile iphone pda }.each do |ending|
      if request.path_info.split('/').last.downcase == ending
        redirect( request.url.sub(/#{ending}\/?$/, 'm/') , 301 )
      end
    end

  end

  if !robot_agent?
    IssueClient.create(env,  options.environment, "404 - Not Found", "Referer: #{env['HTTP_REFERER']}" )
  end

  if request.xhr?
    '<div class="error">Action not found.</div>'
  else
    read_if_file('public/404.html') || "Page not found. Try checking for any typos in the address."
  end

} # === not_found


# ===============================================
# Require the actions.
# ===============================================

require_these 'actions', %w{
  main
  old_app
  heart
  member
  session
  news
	resty
  health
  temp_actions
}

__END__



Mini-Newspaper (for each life, each gets a custom debate page.)
  - Posts
    - view_id 
      1 - Public
      2 - Friends
      3 - Friends & Fans
      4 - Let me select audience:
  - PostComments [ "Important News", "A Random Thought"]
  - PostQuestions [ "Important Question", "A Silly Question" ]
  - PostViewers
  - club_id
  |
Network
  - TightPersons
  - LoosePersons
  - TightPersonInvite
  |
Clubs
  - TodoLists
  - Predictions
  - Questions
  - News (Debates)
  |
TODOS
  |
Pets
  |
Questions 
  |
Translation
  - to English
  - to Japanese
  |
Lunch Dating
  Find Breeder
  Find Partner
  Complain
  Advice/Tips/Warnings
  |
Housing
  Rent Out
  Find
  Mice
  Cleaning
  |
University
  Rate Professors
  Post Warnings/News
  Find/Create A College
  |
Blogs + Newspaper
  |
Travel & Dining
  Find a city
  Post a city
  |
News
  |
Layman Encyclopedia/Search (=Brain)
(Unify Wikipedia-Clone with Google-clone + Bing clone)
  |
Corporal Captitalists (bonds in working individuals)





# ------- TABLES ---------------------
NewsComments
  - news_id
  - status = PENDING || ACCEPTED || REJECTED
  - category = PRAISE || DENOUNCE || FACT CHECK || QUESTION || RANDOM
  - parent_id # for answering questions posted in the comments.
NewsCommentSections

News
  - parent_id # for news branching (predictions or responses).
  - language_id
  - category = DOINGS || NEWS || PREDICTIONS || OPINIONS || QUESTIONS
NewsEdits  




- version 1
  - site permission levels
    - admin
    - editor/moderator
    - unlimited invitations
  - multiple identities
  - pet profiles
    - med condition
  - baby profiles
    - med condition
  - pre-born profiles
    - names
  - fictional profiles
  - photo management
  - youtube linking
  - photo linking
  - guides/pamphlets
  - people mananagement
    - birthdays, anniversaries, important dates, repeating dates

  - Q&A
    - translations
    - vote best answer
    - competance weights
    
    
  - daily and onetime checklists
    - vitamins, etc.
    - countdowns, but no sound  
    - sharable
    - rules-based  
  - project management
    - due dates
      - status
    - milestones
    - files
  - office management
    - tweets
      - labels   
    - news
    - calendar
    - vote for best answer
      - translation
      - gardening
      - engineering
      - etc. 
      
  - invitations
    - gender
    - group
    
  - following
    - friends
    - fans
    - family
    - co-workers
    - frienemies
    - enemies
    - ex-lovers
    
  - tweets with labels   
    - No SMS for now.
   
    
    
- Future version   
  - bug tracking
  - visualize data stream (help handle data overload)
    - inspiration: plurk
  - email broadcasting
    - newsletters paid for 250 or above
  - video management
  - community management 
  - YouTube account connection  
  - Market 
    - local services
      - cleaning
      - food delivery  

  - reputation
    - import/export  
   
  - footprints
    - request to see profile
    - freind only profiles
  
  - universal language

- Create stories for learning alphabet and kanji characters
  - Video.
  - Slides.
- Vote on translations.
- Vote on pronounciation. (MP3/OggVorbis)


Future 
- Job board.
- Advice/Help section
- News section
- Video news w/translation.
- Postcard to Bill Sardi.     
