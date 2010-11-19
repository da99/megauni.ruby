# XML   templates/en-us/xml/Hellos_rss.rb
# CONTROL controls/Hellos.rb
# NAME  Hellos_rss

class Hellos_rss < Base_View

  def posts
    @news ||= Message.news.go!.map { |post|
      {:published_at_rfc822 => rfc822_date(post['created_at']),
       :url => File.join(site_url, 'mess', post['_id'].to_s + '/' ),
       :body => post['body'],
       :title => (post['title'] || "Message: #{post['_id']}") 
      }
    }
  end
  
end # === Hellos_rss
