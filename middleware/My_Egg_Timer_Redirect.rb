
class My_Egg_Timer_Redirect

  def initialize app
    @app = app
  end

  def redirect new_url, stat = 301
    response = Rack::Response.new
    response.redirect( new_url, stat ) # permanent
    response.finish
  end

  def call e
    path_info = e['PATH_INFO']
    if path_info[/\/myeggtimer%../]
      return redirect('/myeggtimer', 301)
    end

    @app.call e
  end

end # === class My_Egg_Timer_Redirect




