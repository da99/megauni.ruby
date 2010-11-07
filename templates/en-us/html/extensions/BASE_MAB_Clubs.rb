
module BASE_MAB_Clubs

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
          mustache 'multiple_usernames?' do
            form.form_follow_create(:action=>"/uni/follow/", :method=>'post') do
              fieldset {
                label 'Follow this club as: ' 
                select(:name=>'username') {
                  mustache('current_member_usernames') {
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
