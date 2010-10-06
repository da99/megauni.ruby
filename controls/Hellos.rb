# tests/Test_Control_Hellos.rb
# tests/Test_Control_Hellos_Mobile.rb
#
class Hellos
  include Base_Control

	top_slash 

  get '/' do
    set_header 'Cache-Control', 'public, max-age=600'
    render_html_template
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
