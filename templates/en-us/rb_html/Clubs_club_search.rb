# VIEW views/Clubs_club_search.rb
# SASS ~/megauni/templates/en-us/css/Clubs_club_search.sass
# NAME Clubs_club_search

div.content! { 
  
  p {
    span.not_found "Club not found:"
    span.filename '{{club_filename}}'
  }

  loop_clubs 'clubs'
  
} # === div.content!

partial('__nav_bar')

