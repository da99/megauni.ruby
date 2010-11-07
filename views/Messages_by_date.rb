# MAB   /home/da01tv/MyLife/apps/megauni/templates/en-us/html/Messages_by_date.rb
# SASS  /home/da01tv/MyLife/apps/megauni/templates/en-us/css/Messages_by_date.sass
# NAME  Messages_by_date

class Messages_by_date < Base_View

  def title 
    "Messages for #{year}/#{month}"
  end

  def year
    app.the.year
  end

  def month
    app.the.month
  end
  
  def messages
    @cache_messages_by_date ||= app.the.messages.map { |mess|
      { 'published_at' => Time.parse(mess['published_at']).strftime(' %b  %d, %Y '),
        'body' => mess['body'],
        'title' => mess['title'],
        'href' => "/mess/#{mess['_id']}/"
      }
    }
  end
  
end # === Messages_by_date 
