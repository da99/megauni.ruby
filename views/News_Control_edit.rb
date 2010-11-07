# MAB   /home/da01/MyLife/apps/megauni/templates/en-us/html/News_Control_edit.rb
# SASS  /home/da01/MyLife/apps/megauni/templates/en-us/css/News_Control_edit.sass
# NAME  News_Control_edit

require 'modules/Enum_Map_Html_Menu'

class News_Control_edit < Base_View
  
  def respond_to? raw_meth
    meth = raw_meth.to_s
    return true  if methods.include?(meth)
    return super if not meth[/\Anews_/] 
    col = meth.sub('news_', '')
    news.data.as_hash.has_key?(col.to_sym)
  end

  def method_missing raw_meth, *args
    meth = raw_meth.to_s
    return super if !meth[/\Anews_/] || !args.empty?
    col = meth.sub('news_', '')
    news.data.send(col)
  end

  def title 
    "Editing: #{news.data.title}"
  end

  def news
    app.the.news
  end

  def clubs
    @clubs ||= \
               with_extension(Club.all_filenames, Enum_Map_Html_Menu).map_html_menu { |club| 
                 news.data.club_id === club
               }
  end

  def news_tags
    @news_tags ||= \
      with_extension(news.data.tags, Enum_Map_Html_Menu) { |tag|
        [ true, {:filename=>tag} ]
      }
  end

  def news_href
    filename, club_type, *rest = news.data._id.split('-')
    File.join('/', filename, club_type, rest.join('-'), '/')
  end

  def news_href_update
    File.join('/news', news.data._id, '/')
  end
  
end # === News_Control_edit 
