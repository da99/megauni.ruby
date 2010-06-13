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
       "{{site_tag_line}}" # Unify
    } 
  }

  ul.help {
    
    nav_bar_li :Hello, 'help'
    
    show_if 'logged_in?' do
      nav_bar_li :Sessions, 'log-out', 'Log-out'
      nav_bar_li :Members, '/today/', '[ Today ]'
      nav_bar_li :Members, '/account/', '[ Account ]'
    end  
    
    show_if 'not_logged_in?' do
      nav_bar_li :Sessions, 'log-in', 'Log-in'
      # nav_bar_li :Member_Control, 'create-account', 'Join'
    end
    
  }

  show_if 'logged_in?' do
    show_if 'no_mini_nav_bar?' do
      p.divider 'Lives' 
    end
    ul.lives {
      mustache 'username_nav' do
        show_if 'selected' do
          nav_bar_li_selected '{{username}}'
        end
        show_if 'not_selected' do
          nav_bar_li_unselected '{{username}}', '{{href}}'
        end
      end
    show_if 'no_mini_nav_bar?' do
      nav_bar_li :Members, :create_life, "/create-life/", "[ Create ]"
    end
    }
  end
  
  # show_if 'no_mini_nav_bar?' do
  #   h4 'Egg Timers'
  #   ul.to_dos {
  #     nav_bar_li :Timer_old, 'my-egg-timer', 'Old Timer'
  #     nav_bar_li :Timer_new, 'busy-noise', 'New Timer'
  #   }
  # end

    # show_if 'development?' do

      # show_if 'not_logged_in?' do
      #   h4 'Non-Members'
      #   ul.non_members {
      #     nav_bar_li :Member_Control, 'create-account', 'Create Account'
      #   }
      # end

    #   h4 'Stuff To Do'
    #   ul.to_dos {
    #       nav_bar_li :Something, 'add-to-do', 'Add to do'
    #       nav_bar_li :To_dos, 'today' 
    #       nav_bar_li :To_dos, 'tomorrow'
    #       nav_bar_li :To_dos, 'this-month', 'This Month'
    #   }

    #   h4 'Lives'
    #   ul.lives {
    #      
    #       nav_bar_li :Lives, 'work'
    #       nav_bar_li :Lives, 'friend'
    #       nav_bar_li :Lives, 'pets', 'Pet Owner'
    #       nav_bar_li :Lives, 'fan'
    #       nav_bar_li :Lives, 'relatives'
    #       nav_bar_li :Lives, 'parenting'
    #       nav_bar_li :Lives, 'education'
    #       nav_bar_li :Lives, 'love'
    #       nav_bar_li :Lives, 'secret', 'Secret Life'
    #   }
    # 
    # end # === if development?

  show_if 'no_mini_nav_bar?' do
    p.divider 'Clubs'
    ul.news {

      # li "San Francisco" #  (Survival Tips + Marketplace)
      # li "Tokyo" # (+ Translate Please)
      # li "Vote For More Clubs"
      # li "- How I Train My Boyfriend"
      # li "- Introverts"
      # li "- Obama-rific" #  (Politics + News)
      # li "City Clubs "
      # li "- Multiple Languages"
      # li "- Carpooling"
      # li "- Garage Renting"
      # li "Tropical Physician Ratings" 
      

      # nav_bar_li nil, 'salud',    'Salud (Español)'
      # nav_bar_li :Topic, 'back_pain', 'Back Pain'
      # nav_bar_li :Topic, 'child_care', 'Child Care'
      # nav_bar_li :Topic, 'computer', 'Computer Use'
      # 
      # nav_bar_li :Topic, 'hair',     'Skin & Hair'
      # nav_bar_li :Topic, 'housing',  'Housing & Apartments'
      # nav_bar_li :Topic, 'health',   'Pain & Disease'
      # nav_bar_li :Topic, 'preggers', 'Pregnancy'
      
      
      nav_bar_li :Clubs, :list, '/clubs/', '[ View All ]'
      
      show_if 'logged_in?' do
        nav_bar_li :Clubs, :create, '/club-create/', '[ Create ]'
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

  # h4 'Pain & Disease'
  # ul.human_body { 
  #   nav_bar_li.call '/arthritis/',  'Arthritis (osteo & rhumatoid)', :topic, :arthritis
  #   nav_bar_li.call '/back-pain/',  'Back Pain',           :topic, :back_pain
  #   nav_bar_li.call '/cancer/',     'Cancer',              :topic, :cancer
  #   nav_bar_li.call '/dementia/',   'Dementia/Alzheirmer', :topic, :dementia
  #   nav_bar_li.call '/depression/', 'Depression',          :topic, :depresssion
  #   nav_bar_li.call '/flu/',        'Flu/Cold',            :topic, :flu
  #   nav_bar_li.call '/heart/',      'Heart & Diabetes',   :topic, :heart
  #   nav_bar_li.call '/hiv/',        'HIV/AIDS/STDs',       :topic, :hiv
  #   nav_bar_li.call '/meno-osteo/', 'Osteoporosis & Menopause',      :topic, :meno_osteo
  #   nav_bar_li.call '/health/',     'Other Health',        :topic, :health
  # }



    # ['/apartments/', 'Houses & Apartments', :housing, :index],
    # ['/lingua/', 'Translate', :lingua, :index],
    # ['/dating/', 'Lunch Date', :dating, :index],
    # ['/pets/', 'Pets & Mascots', :pets, :index],
    # ['/secrets/', 'Secrets', :health, :index],
    # ['/make-overs/', 'Make-overs', :health, :makeovers],
    # Home/Apartment.
    # 
    # Office Help.
    #  Daily Summary.
    #  To-Dos.
    #  Projects
    #  Calendar
    #  Create Global To-Do List.
  
} # === div.nav_bar!
