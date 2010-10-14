class Inspect_Control
  include Base_Control

  def GET_list 
    file_contents = File.read(File.expand_path(__FILE__)).split("\n")
    end_index     = file_contents.index('__' + 'END' + '__')
    
    render_html_template
  end
  
  def GET_request 
    if Uni_App.development?
      render_text_html "<pre>" + request.env.keys.sort.map { |key| 
        key.inspect + (' ' * (30 - key.inspect.size).abs) + ': ' + request.env[key].inspect 
      }.join("<br />") + "</pre>"
    else
      raise Uni_App::HTTP_404, "/request only allowed in :development environments."
    end
  end
  
end # === Request_Bunny
