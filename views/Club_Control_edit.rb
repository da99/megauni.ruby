# MAB   /home/da01/MyLife/apps/megauni/templates/en-us/html/Club_Control_edit.rb
# SASS  /home/da01/MyLife/apps/megauni/templates/en-us/css/Club_Control_edit.sass
# NAME  Club_Control_edit

class Club_Control_edit < Club_Control_Base_View

  def title 
    "Editing Club: #{club.data.title}"
  end

  def news
    @news ||= News.by_club_id_and_published_at(:club=>club.data._id, :limit=>5).map { |post|
      post.update(
        :href=>href_for(post),
        :href_edit=>href_for(post, :edit)
      )
    }
  end
  
end # === Club_Control_edit 
