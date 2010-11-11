# /home/da01/megauni/views/Account_list.rb

partial('__nav_bar')


div.content!  { 

  div.usernames {
    h4 'Usernames'
    a.new('Add Another Username.', :href=>'#add_username')
    loop 'lifes' do
      div.un(:id=>"life_{{category}}") {
        div.username '{{username}}' 
        div.category '{{category}}' 
        a.edit("Edit", :href=>'#edit_username')
      }
    end
  }

  div.delete_account! {
    h4 'Delete Everything.'
    div.msg "Once you delete your account, all usernames,
      all data,
      will be lost permanently. 
      For your privacy, there is no going back. No undo.
      It will be as if you never existed on this website."
    a.delete('Delete Entire Account', :href=>'#delete')
  }

} # === div
