# VIEW views/Clubs_by_id.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/sass/Clubs_by_id.sass
# NAME Clubs_by_id

div.content! { 
  
  partial '__flash_msg'

  h3 '{{club_title}}'
  
  mustache 'logged_in?' do
  
    mustache 'follower?' do
      p "You are following this club."
    end

    mustache 'potential_follower?' do
			mustache 'single_username?' do
				a("Follow this club.", :href=>"{{follow_href}}")
			end
			mustache 'multiple_usernames?' do
				form.form_follow_create!(:action=>"/clubs/follow/", :method=>'post') do
					label 'Follow this club as: '
					select {
						mustache('current_member_usernames') {
							option('{{username}}', :value=>'{{username}}')
						}
					}
					button 'Follow.'
				end
			end
    end

    div.club_message_create! do
      h4 'Post a message:'  
      form :id=>"form_club_message_create", :method=>'POST', :action=>"/messages/" do
        
        input :type=>'hidden', :name=>'club_filename', :value=>'{{club_filename}}'
        input :type=>'hidden', :name=>'privacy', :value=>'public'
        
        mustache 'single_username?' do
          input :type=>'hidden', :name=>'username', :value=>'{{first_username}}'
        end
        
        fieldset {
          textarea '', :name=>'body'
        }

        fieldset {
          label "Labels (Separate each with a comma.)"
          input.text :type=>'text', :name=>'public_labels', :value=>''
        }
        
        div.buttons {
          button.create 'Save'
        }
        
        mustache 'multiple_usernames?' do
          fieldset {
            label 'Which life to use?'
            select(:name=>'owner_id') {
              mustache 'multiple_usernames' do
                option '{{username}}', :value=>'{{username}}'
              end
            }
          }
        end
      end
    end
  end

  div.club_messages! do
    mustache 'no_messages_latest' do
      div.empty_msg 'No messages yet.'
    end
    mustache 'messages_latest' do
      div.message {
        div.body( '{{{compiled_body}}}' )
        div.permalink {
          a('Permalink', :href=>"{{href}}")
        }
      }
    end
  end
  
} # === div.content!


partial('__nav_bar')

