# VIEW ~/megauni/views/Hellos_sitemap.rb
# NAME Hellos_sitemap

instruct!
urlset "xmlns" => "http://www.google.com/schemas/sitemap/0.84" do

  url do
    loc         '{{site_url}}'
    lastmod     '{{last_modified_at}}'
    changefreq  "daily"
  end
  
  self << '{{# news }}'
    url do
      loc     '{{url}}'
      lastmod '{{last_modified_at}}'
      changefreq  "monthly"
    end
  self << '{{/ news }}'

end
