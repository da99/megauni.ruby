# ~/megauni/views/Base_View.rb
# ~/megauni/templates/en-us/sass/layout.sass

div( :id=>"nav_bar" ) { 

  div( :id=>"logo" ) { 
    p.english { 
      if template_name == :Hello_list
              '{{site_title}}' 
      else
        a '{{site_title}}', :href=>'/'
      end
    }
    p.divider.site_tag_line {
       '~~ ? ! @ ~~'
    } 
  }

  ul.help {
    
    nav_bar_li :Hello, 'help'
    
    show_if 'logged_in?' do
      nav_bar_li :Sessions, 'log-out', 'Log-out'
      nav_bar_li :Members, '/lifes/', '[ My Lifes ]'
    end  
    
    show_if 'not_logged_in?' do
      nav_bar_li :Sessions, 'log-in', 'Log-in'
      # nav_bar_li :Member_Control, 'create-account', 'Join'
    end
    
  }

  show_if 'logged_in?' do
    show_if 'not_mini_nav_bar?' do
      p.divider 'Lives' 
    end
    ul.lives {
      mustache 'username_nav' do
        show_if 'selected?' do
          nav_bar_li_selected '{{username}}'
        end
        show_if 'not_selected?' do
          nav_bar_li_unselected '{{username}}', '{{href}}'
        end
      end
    show_if 'not_mini_nav_bar?' do
      nav_bar_li :Members, :create_life, "/create-life/", "[ Create ]"
    end
    }
  end
  
  # show_if 'not_mini_nav_bar?' do
  #   h4 'Egg Timers'
  #   ul.to_dos {
  #     nav_bar_li :Timer_old, 'my-egg-timer', 'Old Timer'
  #     nav_bar_li :Timer_new, 'busy-noise', 'New Timer'
  #   }
  # end

    # show_if 'development?' do


    #   h4 'Stuff To Do'
    #   ul.to_dos {
    #       nav_bar_li :Something, 'add-to-do', 'Add to do'
    #       nav_bar_li :To_dos, 'today' 
    #       nav_bar_li :To_dos, 'tomorrow'
    #       nav_bar_li :To_dos, 'this-month', 'This Month'
    #   }

    # end # === if development?

  p.divider 'Clubs'
  ul.clubs {

    nav_bar_li :Clubs, :list, '/clubs/', '[ View All ]'
    
    show_if 'logged_in?' do
    end
  
  }
  
  show_if 'logged_in?' do

    p.divider 'Your Clubs'

    ul.your_clubs {

      nav_bar_li :Clubs, :create, '/club-create/', '[ Create ]'

      loop 'your_clubs' do
        li { a("{{title}}", :href=>'{{href}}') }
      end

    }
  end

  show_if 'mini_nav_bar?' do
    ul {
      li {
        nav_bar_li :Clubs, :list, '/clubs/', 'Clubs'
      }
    }
  end

} # === div.nav_bar!
