# mab   ~/megauni/templates/en-us/xml/Hellos_sitemap.rb
# SASS  ~/megauni/templates/en-us/css/Hellos_sitemap.sass
# NAME  Hellos_sitemap

class Hellos_sitemap < Base_View

  def last_modified_at
    latest_post = news.first
    return w3c_date(Time.now.utc) if not latest_post
    news.first[:last_modified_at]
  end

  def news
    @news ||= Message.by_published_at(:limit=>5, :sort=>[:published_at, :desc]).map { |post|
      {:last_modified_at => w3c_date(post['updated_at'] || post['created_at']),
       :url => File.join(site_url, 'mess', post['_id'].to_s + '/' ) }
    }
  end

end # === Hello_sitemap_xml 
