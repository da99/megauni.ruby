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
# 
# 	get '/' do
# 		%~
# 			<p>It works: #{rand(10_000_000)}.</p>
# 		<a href="/hello-world/">Say hello.</a>
# 		~
# 	end

  get '/' do
    set_header 'Cache-Control', 'public, max-age=601'
		uni 'test uni'
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
