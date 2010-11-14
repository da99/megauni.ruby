
module Ruby_To_Html::Base_Member_Life

  def div_filter_options type
    div.col.filter! {
      filter_options type
    }
  end

  def filter_options type
    
      h4 'Filter by life:'
      ul {
        loop('usernames') {
          li { a! 'username', "href_#{type}"}  
        }
      }
      
      show_if('clubs_not_owned?') {
        h4 'Filter by universe:'
        ul {
          loop 'clubs_not_owned' do
            li { a! 'title', "href_#{type}" }
          end
        }
      }
      
  end

  def member_nav_bar filename
    file     = File.basename(filename).sub('.rb', '')
    li_span  = lambda { |txt| li.selected { span txt } }
    li_ahref = lambda { |txt, href| li { a('txt', :href=>href) } }
    vals = [ 
      [/_follows\Z/      , 'Follows'     , '/follows/']         , # \Helps + Mind Control
      [/_notifys\Z/      , 'Notifys'     , '/notifys/']         , #  \  Filters of: Secret Unis         , Unis, Contacts, Memberships
      [/_lifes\Z/        , 'Lifes & UNIs', '/lifes/']           , #   \
      [ /_help\Z/        , 'Help'        , '/help/'] ,
      # [/_news\Z/       , 'Calendar'    , 'news/']            ,  
      # [/_shop\Z/       , 'To-dos'      , 'shop/']            ,  
      # [/_predictions\Z/, 'Contacts'    , 'predictions/']     , 
    ]
    text(capture {

      ul.nav_bar.member_nav_bar! {
        vals.each { |trip|
          if file =~ trip[0]
            li.selected  trip[1] 
          else
            li { a trip[1], :href=>trip[2]  }
          end
        }

        show_if 'logged_in?' do
          li { a('Log-out', :href=>'/log-out/') }
        end
        
        li { a('Megauni', :href=>'/') }
      } # ul
      
    })
  end # === def member_nav_bar

  def life_club_nav_bar filename
    file     = File.basename(filename).sub('.rb', '')
    li_span  = lambda { |txt| li.selected { span txt } }
    li_ahref = lambda { |txt, href| li { a('txt', :href=>href) } }
    vals = [ 
      [/_life\Z/  , 'Home'        , '']       ,
      [/_e\Z/     , 'Encyclopedia', 'e/']     ,
      [/_qa\Z/    , 'Q & A'       , 'qa/']    ,
      [/_news\Z/  , 'News'        , 'news/']  ,
      [/_shop\Z/  , 'Shop'        , 'shop/'],
      [/_predictions\Z/, 'Predictions'      , 'predictions/'],
      [/_random\Z/, 'Random'      , 'random/']
    ]
    text(capture {

      ul.club_nav_bar! {
        vals.each { |trip|
          if file =~ trip[0]
            li.selected  trip[1] 
          else
            li { a(trip[1], :href=>'{{life_club_href}}' + trip[2] ) }
          end
        }

        show_if 'logged_in?' do
          li { a('Log-out', :href=>'/log-out/') }
        end

        if_not 'logged_in?' do
          li { a('Log-in', :href=>'/log-in/') }
        end
        
        li { a('Megauni', :href=>'/') }
      } # ul
      
 
      # mustache('logged_in?') {

      #   mustache 'follower?' do
      #     p "You are following this club."
      #   end

      #   mustache 'potential_follower?' do
      #     mustache 'single_username?' do
      #       p {
      #         a("Follow this club.", :href=>"{{href_follow}}")
      #       }
      #     end
      #     mustache 'multiple_usernames?' do
      #       form.form_follow_create!(:action=>"/uni/follow/", :method=>'post') do
      #         fieldset {
      #           label 'Follow this club as: ' 
      #           select(:name=>'username') {
      #             mustache('current_member_usernames') {
      #             option('{{username}}', :value=>'{{username}}')
      #           }
      #           }
      #         }
      #         div.buttons { button 'Follow.' }
      #       end
      #     end
      #   end

      # }

      
      
    })
  end


end # === module
