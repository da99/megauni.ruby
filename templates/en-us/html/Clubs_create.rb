# VIEW views/Clubs_create.rb
# SASS /home/da01tv/MyLife/apps/megauni/templates/en-us/css/Clubs_create.sass
# NAME Clubs_create

div.content! { 
  
  h4 'Create a Club'

  form(:id=>'form_clubs_create', :action=>"/uni/", :method=>"post") {
    fieldset {
      label 'Title:'
      input.text :name=>'title', :id=>'create_club_title', :type=>'text', :value=>''
    }
    fieldset {
      label 'Filename:'
      input.text :name=>'filename', :id=>'create_club_filename', :type=>'text', :value=>''
    }
    fieldset {
      label 'Description:'
      textarea '', :name=>'teaser', :id=>'create_club_teaser'
    }
    div.buttons {
      button 'Save'
    }
  }

  a('See complete list of clubs.', :href=>'/uni/')
  
} # === div.content!

partial('__nav_bar')

