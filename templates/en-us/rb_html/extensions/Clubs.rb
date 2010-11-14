
module Ruby_To_Html::Controls::Clubs

  def loop_clubs list_name, &blok
    text(capture {
      loop list_name do 
        div.club {
          h4 {
            a('{{title}}', :href=>'{{href}}')
          }
          show_if 'teaser?' do
            div.teaser '{{teaser}}'
          end
          
          loop_messages 'messages', &blok
        }
      end
    })
  end

  def club_nav_bar filename
    
    file = File.basename(filename).sub('.rb', '')
    vals = [
      [/_filename\Z/   , 'Home'               , '']            ,
      [/_e\Z/          , 'Encyclopedia'       , 'e/']          ,
      [/_news\Z/       , 'News'               , 'news/']       ,
      [/_magazine\Z/       , 'Magazine'               , 'magazine/']       ,
      [/_fights\Z/     , 'Fights', 'fights/']     ,
      [/_qa\Z/         , 'Q & A'              , 'qa/']         ,
      [/_shop\Z/       , 'Shop'               , 'shop/']       ,
      [/_predictions\Z/, 'Predictions'        , 'predictions/'],
      [/_random\Z/     , 'Random'             , 'random/'],
      [/_thanks\Z/     , 'Thanks'             , 'thanks/']
    ]
    
    text(capture {
      
      ul.nav_bar.club_nav_bar! {
        vals.each { |trip|
          if file =~ trip[0]
            li.selected  { trip[1] }
          else
            li { a(trip[1], :href=>'{{club_href}}' + trip[2] ) }
          end
        }

        show_if 'logged_in?' do
          li { a('Log-out', :href=>'/log-out/') }
        end

        if_not 'logged_in?' do
          li { a('Log-in', :href=>'/log-in/') }
        end
        
        if_not 'logged_in?' do
          li { a('megaUNI.com', :href=>'/') }
        end
        
        show_if 'logged_in?' do
          li { a('My Lifes', :href=>'/lifes/') }
        end
      } # ul
      
    })
  end


  def pretension!
    div.pretension! {
      partial '__club_title'
    }         
  end

  def messages! &blok
    div.col.messages! &blok
  end

  def messages_or_guide
    all_lists = case messages_list
                when String
                  loop_messages messages_list
                  messages_list
                when Array
                  messages_list.inject([]) { |lists, hash|
                    list, header = hash.first
                    loop_messages_with_opening list, header
                    lists << list
                  }.join('_or_')
                end
    
    if_not(all_lists + '?') do
      publisher_guide
    end
    
  end
  
  def omni_follow
    show_if('logged_in?') {

      div.sections.follow {
        show_if 'follower_but_not_owner?' do
          h3.following_it 'You are following this universe.'
        end
  
        show_if 'potential_follower?' do
          show_if 'single_username?' do
            div.follow_it {
              a_button("Follow this universe.", "href_follow".m! )
            }
          end
          show_if 'multiple_usernames?' do
            form.form_follow_create(:action=>"/uni/follow/", :method=>'post') do
              fieldset {
                label 'Follow this club as: ' 
                select(:name=>'username') {
                  loop('current_member_usernames') {
                    option('{{username}}', :value=>'{{username}}')
                  }
                }
              }
              div.buttons { button 'Follow.' }
            end
          end
        end
        
        show_if 'follows?' do
          div.section.follows_list {
            h3 'You are following:'
            ul {
              loop 'follows' do
                li { a! 'title', 'href'  }
              end
            }
          } # === div.follows_list!
        end
          
        show_if 'follower_but_not_owner?' do
          delete_form 'follow' + rand(1000).to_s do
            action 'href_delete_follow'.m!
            submit {
              a_click 'Unfollow'
            }
          end
        end
      } # === follow!
    }
  end
  alias_method :follow, :omni_follow

  
  def not_life? &blok
    show_if 'not_life?', &blok
  end

end # === module
