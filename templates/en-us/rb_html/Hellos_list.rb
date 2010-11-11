# ~/megauni/views/Hellos_list.rb
# ~/megauni/templates/en-us/css/Hellos_list.sass


div.col.pretension! {

  div.coming_soon! {
    strong %~ Coming Soon ~
  }

  h1 '{{site_tag_line}}'
  
  p {
    span 'Entertain your friends with your own online universe. Each universe includes: '
    
    strong 'encyclopedia'
    span ' section for memorable moments, '
    
    strong 'magazine'
    span ' section for stories and articles, '
    
    strong 'news'
    span ' section for timely updates, '
    
    strong 'predictions'
    span ' section, '
    
    strong 'q & a'
    span ' section where people ask you questions, '
    
    strong 'shopping'
    span ' section to publicize your favorite buys, '
    
    span 'and a '
    strong 'random'
    span 'section where you can post anything.'
    
  }

  p { 
    span %~
    Your friends can also post stuff to your universe: 
    ~
    strong 'stories'
    span ', '
    strong 'predictions'
    span ', '
    strong 'questions'
    span ', '
    strong 'random stuff'
    span ', etc.'
  }
  
div.footer! {
  span "(c) {{copyright_year}} {{site_domain}}. Some rights reserved."
} # the_footer


} # === div

div.col.middle! {
  div.intro! {

    form.search_club_form!(:action=>"/club-search/", :method=>"post") {
      fieldset {
        label 'Find by keyword:'
        input.text(:id=>'club_keyword', :name=>'keyword', :type=>'text', :value=>'')
      }
      div.buttons {
        button.create 'Go', :onclick=>"document.getElementById('search_club_form').submit(); return false;"
      }
    } # form

    p {
      span 'Tip: Link to '
      a( 'menopause/osteo', :href=>'/uni/meno_osteo/')
      span ' is fixed.'
    }

  } # div.intro!


  div.nav_bar! { 
    
    ul.nav_bar.help {
      
      li {
      }
      
      show_if 'logged_in?' do
        li {
          a 'Log-out', :href=>'log-out' 
        }
      end  
      
      # show_if 'not_logged_in?' do
      #   li {
      #     a 'Log-in', :href=>'/log-in/'
      #   }
      # end
      
    }

    show_if 'logged_in?' do
      
      h4 'Lifes' 
      
      ul.nav_bar.lifes {
        loop 'usernames' do
          nav_bar_li_unselected '{{username}}', '{{href}}'
        end
        nav_bar_li :Members, 'follows', "[ Follows ]"
        nav_bar_li :Members, 'notifys', "[ Notifys ]"
        nav_bar_li :Members, 'lifes', "[ Create Life ]"
      }
    end
    
    h4 'Egg Timers'
    
    ul.nav_bar.to_dos {
      nav_bar_li :Timer_old, 'my-egg-timer', 'Old'
      nav_bar_li :Timer_new, 'busy-noise', 'New'
    }

    h4 'Old Stuff'
    
    ul.nav_bar.old_clubs {
      loop 'old_clubs' do
        li { a('{{title}}', :href=>'{{href}}') }
      end
    }
    
    h4 'New Universes'
    
    ul.nav_bar.new_stuff {
      li { a('Vitamin Fanatics', :href=>'/uni/vitamins/') }
    }

  } # === div.nav_bar!


} # === div.col




  # h4 %~ A universe lets you: ~

  # ul {
  #   li {
  #     strong 'Make a Personal Encyclopedia'
  #     span ': You and your friends
  #       write in this section to record important
  #       moments of your life.'
  #   }
  #   
  #   li {
  #     strong 'Q & A Section'
  #     span ': Answer questions people throw
  #       at you.'
  #   }
  #   
  #   li {
  #     strong 'Magazine Section'
  #     span ': A place to write long stories: travel, reviews, eloquent rants, or explain why you got arrested last Saturday.'

  #   }

  #   li {
  #     strong 'Random Section'
  #     span ': Post random thoughts that cross
  #       your messy mind.'
  #   }

  #   li {
  #     strong 'Fights Section'
  #     span ': Discuss & debate ideas with others in a friendly fashion.'

  #   }
  #   
  #   li {
  #     strong 'Shop Section'
  #     span %~: Tell others about the products you love or hate.~

  #   }
  #   
  #   li {
  #     strong 'News Section'
  #     span ': Important things people should know.'

  #   }
  #   
  #   li {
  #     strong %~Make Requests to Friends~
  #     span %~: Ask friends to entertain you by posting messages.~
  #   }

  #   li {
  #     strong 'Predictions Section'
  #     span ': Record your efforts to see into the future.'

  #   }
  #   li {
  #     strong '"Thank You" Section'
  #     span ': People post a thank you note when you do something kind.'
  #   }

  #   li {
  #     strong %~Mind Control Made Fun & Easy~
  #     span %~: Bored? Let {{site_domain}} take over your mind.~
  #   }
  # # } # === ul

  # # # h4 %~ Other features: ~

  # # ul {
  #   
  #   li {
  #     strong %~Multiple Lifes~
  #     span %~: Create different usernames for your work life, home life, babies, pets, fantasy life, etc.~
  #   }
  #   
  #   li {
  #     strong %~No Popularity Contests~
  #     span %~: The total number of followers is kept secret to avoid spam and publicity hounds.~
  #   }

  #   li {
  #     strong %~Re-posting for easy sharing.~
  #     span %~: Find something you like in someone else's universe? You can re-post it easily with your own custom intro.~
  #   }

  #   
  # } # === ul




