# ~/megauni/views/Base_View.rb
# ~/megauni/templates/en-us/css/layout.sass

div( :id=>"nav_bar" ) { 

  div( :id=>"logo" ) { 
    p.site_title { 
      a '{{site_title}}', :href=>'/'
    }
    h4 {
      '~~ ? ! @ ~~' 
    } 
  }

  ul {
    
    nav_bar_li :Hello, 'help'
    
    mustache 'logged_in?' do
      nav_bar_li :Session_Control, 'log-out', 'Log-out'
      # nav_bar_li :Members, '/today/', '[ Today ]'
      nav_bar_li :Members, '/lifes/', '[ My Lifes ]'
    end  
    
    mustache 'not_logged_in?' do
      nav_bar_li :Session_Control, 'log-in', 'Log-in'
      # nav_bar_li :Member_Control, 'create-account', 'Join'
    end
    
  }

  mustache 'logged_in?' do
    h4 'Lifes'
    ul {
      mustache 'username_nav' do
      mustache 'selected?' do
        nav_bar_li_selected '{{username}}'
      end
      mustache 'not_selected?' do
        nav_bar_li_unselected '{{username}}', '{{href}}'
      end
      end
      nav_bar_li :Members, :create_life, "/lifes/", "[ Create Life ]"
    }
  end

  h4 'Clubs'
  ul {
    li {
      nav_bar_li :Clubs, :list, '/uni/', '[ View All ]'
    }
    mustache 'logged_in?' do
      nav_bar_li :Clubs, :create, '/club-create/', '[ Create ]'
    end
  } # === ul

  
} # === div.nav_bar!
