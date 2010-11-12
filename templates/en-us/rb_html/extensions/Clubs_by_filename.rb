# MAB     ~/megauni/templates/en-us/html/Clubs_by_filename.rb
# VIEW    ~/megauni/views/Clubs_by_filename.rb
# SASS    ~/megauni/templates/en-us/css/Clubs_by_filename.sass
# NAME    Clubs_by_filename
# CONTROL models/Club.rb
# MODEL   controls/Club.rb
# 


module Ruby_To_Html::Actions::Clubs_by_filename

  module STRANGER
    
    def about
      super("About this {{club_type}}:", 'club_teaser')
    end
    
  end # === module

  module MEMBER
    
    def about
      super("About this {{club_type}}:", 'club_teaser')
    end
    
  end # === module

  module INSIDER
    
    def publisher_guide
      guide('Stuff you should do:') {
        ul {
          li "Share a memory in \"Encyclopedia\" section."
          li "Share fun webpages in \"Random\" section."
          li %~ Visit "Q & A" section. ~
        }
      }
    end
    
    def about
      super "You're an insider:", 'club_teaser'
    end
  end # === module

  module OWNER
    
    def memberships 
      super('all')
      
      show_if 'memberships?' do
        div.section.memberships {
          h4 'Memberships:'
          ul {
            loop 'all_memberships' do
              li { a! "Withdraw as: #{'name'.m!}", 'href' }
            end
          }
        }
      end
      
      div.section.add_memberships {
        h4 'Add Members:'
        p %~Members are given special powers.
        Separate each with a new line.~
        form_post('add_member' + rand(1000).to_s) {
          textarea '!!add here!!'
        }
      } # === add_memberships!
    end # === memberhips

    def messages
      loop_messages 'all_messages'
    end

    def memberships_list
      'all_memberships'
    end
    
    def publisher_guide
      guide('Stuff you should do:') {
        ul {
          li "Post something in the \"Encyclopedia\" section."
          li "Write anything in the \"Random\" section."
          li %~ Recommend a product in the "Shop" section. ~
          li %~ Ask a question in the "Q & A" section. ~
        }
      }
    end

    def post_membership!
      div.section { p 'Post form membership goes here.' }
    end
    
    def memberships_guide!
      div.section { p 'Memberrship guide goes here.' }
    end
    
    def about
      super(
        "This {{club_type}} is yours:", 
        'You own it. You can edit it, destroy it, or publish to it.'
      )
    end
    
    def edit!
      div.edit_settings! {
        a_button 'Edit settings.', 'href_edit'   
        p %~
          Edit title, teaser, or choose to delete this {{club_type}}
        ~
      }
    end
  end # === module

  def memberships_list
    'public_memberships'
  end

  def publisher_guide
  end

  def messages_list
    'messages_latest' 
  end

  def messages
    loop_messages "public_messages"
  end

  # =============== publisher_guide

  def follow!
    return super
    show_if('logged_in?') {

      div.sections.follow! {
        show_if 'follower_but_not_owner?' do
          h3.following_it! 'You are following this universe.'
        end
  
        show_if 'potential_follower?' do
          show_if 'single_username?' do
            div.follow_it! {
              a.button("Follow this universe.", :href=>"href_follow".m! )
            }
          end
          show_if 'multiple_usernames?' do
            form.form_follow_create!(:action=>"/uni/follow/", :method=>'post') do
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
          div.section.follows_list! {
            h3 'You are following:'
            ul {
              loop 'follows' do
                li { a! 'title', 'href'  }
              end
            }
          } # === div.follows_list!
        end
          
        show_if 'follower_but_not_owner?' do
          delete_form 'follow' do
            action 'href_delete_follow'.m!
            submit {
              a_click 'Unfollow'
            }
          end
        end
      } # === follow!
    }
  end # === div_follow

  # =============== MEMBERSHIPS

  def memberships! &blok
    div.col.memberships! &blok
  end

  def memberships security = 'public'
    
    show_if 'memberships?' do
      h3 'Members:'
    end
    
    loop "#{security}_memberships" do
      div {
        div 'title'.m!
        div 'privacy'.m!
      }
    end
    
  end # === def
   
  def post_membership_plea
    form_post("plea_#{rand(100)}") {
      p 'not done'
    }
  end


end # === module
