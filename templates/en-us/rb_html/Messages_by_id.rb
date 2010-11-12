# VIEW ~/megauni/views/Messages_by_id.rb
# SASS ~/megauni/templates/en-us/css/Messages_by_id.sass
# NAME Messages_by_id
# MODEL models/Message

show_if 'show_moving_message?' do
  div.notice! {
    span "I'm moving content from my old site, "
    a('SurferHearts.com', :href=>'http://www.surferhearts.com/') 
    span ", over to this new site."
  }
end

h3.club_title! '{{club_title}}' 

club_nav_bar __FILE__

h3.message_title '{{title}}'

div.substance! { 
  
    div.message!{

      as 'data' do
        div.body { '{{{compiled_body}}}' }
      end

      show_if 'logged_in?' do
        
        div.notify_me! {
        
          if_not 'notify_me?' do
              
            post_to_username('notify') {
              as_radios
              action '{{href_notify}}'
              button_create 'Notify me.'
              show {
                a_click 'Notify me '
                span ' of activity for this {{message_model_in_english}}.'
              } # === show 
            }
            
          end
        
          show_if 'notify_me?' do  
            delete_form('notify') {
              action "{{href_notify}}"
              submit {
                a_click 'Stop'
                span ' notifying me.'
              }
            }
          end
          
        } # === div.notify_me!
        
        if_not 'reposts?' do
          div.repost! {
            
            post_to_universes(:repost) {
              action "{{href_repost}}"
              button_create 'Re-post.'
              show 'Re-post.'
            }
              
          } # === div
        end

      end # === show_if 'logged_in?'
      

      div.about! {

        h4 'About this content:'
        
        div {
          strong "Published on:"
          br
          span '{{published_at}}'
        }
        
        div {
          strong "Type:"
          br
          span "{{message_model_in_english}}."
        }
        
        div {
          strong 'Publication:'
          br
          a('{{club_title}}', :href=>'{{href_club}}')
        }
        
        div {
          strong 'Section: '
          br
          a('{{message_section}}', :href=>'{{href_section}}')
        }
        
        show_if 'has_parent?' do
          div {
            strong 'A reply to:'
            br
            a('this message', :href=>'{{href_parent}}')
          }
        end

        show_if 'updator?' do
          div {
            strong 'Actions:'
            br
            a('Edit.', :href=>'{{href_edit}}')
            show_if 'updated?' do
              br 
              a('View changes.', :href=>'{{href_log}}')
            end
          }
        end

      } # div.about!

      div.replies! {

        div.responds! {
          [ 
            ['suggests', '{{suggestions_or_answers}}'],
            ['critiques', 'Praise & Criticism:'],
            ['questions', 'Questions:']
          ].each { |mod, txt|
            show_if "#{mod}?" do
              div(:id=>mod) {
                h4 txt
                loop_messages(mod)
              } 
            end
          }

        } # === div.responds!

        show_if 'logged_in?' do
          
          div.reply! {
            
            div.guide! {
              h4 'Stuff you can do:'
              p %~
                Express negative feelings. Try to use
              polite profanity, like meathead instead of 
              doo-doo head.
              ~
            }
            
            post_message {
              title 'Publish a new:'
              models %w{cheer jeer question suggest}
              hidden_input(
                :parent_message_id => '{{_id}}',
                :privacy           => 'public'
              )
            }
            
          } # === div.reply!
          
        end # logged_in?
        
      } # === div.reply!
  
  
    } # === div.message!
} # === div.substance!

show_if 'logged_in?' do
  render_toggle_forms
end
