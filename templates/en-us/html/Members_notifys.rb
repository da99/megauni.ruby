# VIEW ~/megauni/views/Members_notifys.rb
# SASS ~/megauni/templates/en-us/css/Members_notifys.sass
# NAME Members_notifys
# CONTROL models/Member.rb
# MODEL   controls/Member.rb

member_nav_bar __FILE__

div.col.notifys! {
  if_empty 'notifys' do
    div 'You have no notifys.'
  end

  loop_messages 'notifys'
} # === notifys!

div_filter_options 'notifys'

