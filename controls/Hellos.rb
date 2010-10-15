# tests/Test_Control_Hellos.rb
# tests/Test_Control_Hellos_Mobile.rb
#
class Hellos
  include Base_Control

  top_slash 

  get '/' do
    action :list
    cache_for 5
    render :text, 'Hello, World'
    template :html
  end

  get '/salud' do
    template :html
  end

  get '/help' do
    template :html
  end

  get '/sitemap.xml' do
    template :xml
  end

  get '/rss.xml' do
    template :xml
  end

end # === Hello
