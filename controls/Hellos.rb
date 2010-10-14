# tests/Test_Control_Hellos.rb
# tests/Test_Control_Hellos_Mobile.rb
#
class Hellos
  include Base_Control

  top_slash 

  get '/hello-world' do
    %~
      <p>Hello, World.</p>
    <a href="/">See front page.</a>
    ~
  end

  get '/' do
    action :test
    cache_for 5
    
    "#{control} #{action}"
    "#{response.headers.has_key?('Cache-Control').inspect}"
    # render_html_template
  end

  get '/salud' do
    render_html_template
  end

  get '/help' do
    render_html_template
  end

  get '/sitemap.xml' do
    render_xml_template
  end

  get '/rss.xml' do
    render_xml_template
  end

end # === Hello
