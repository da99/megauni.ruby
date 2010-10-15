
module Sinatra
  
  module Uni_Render

    def template alt_file_name = nil
      case alt_file_name
      when :html, :xml, :text
        ext       = alt_file_name
        file_name = "#{control}_#{action}"
      else
        ext       = alt_file_name.split('.').first.to_sym
        file_name = alt_file_name 
      end
      
      # return render(:text, path_to_file)
      
      # Process the template.
      template_content = process_mustache(ext, file_name)

      render ext, template_content
    end # === def template

    def render type, txt
      header(:accept_charset, 'utf-8') unless header?(:accept_charset)
      no_cache unless header?(:cache_control)
      content_type type
      txt
    end

    def process_mustache ext, file_name

      template_content = if Uni_App.production? 
                           File.read(mustache)
                         else
                           disguise = case ext
                                      when :html
                                        'Mab'
                                      when :xml
                                        'Xml'
                                      else
                                        raise ArgumentError, "Don't know what to do with: #{file_path}"
                                      end
                                        
                           original    = "templates/#{lang}/#{disguise.downcase}/#{file_name}.rb"
                           file_path   = "templates/#{lang}/#{disguise.downcase}/#{file_name}.#{ext}"
                           time_format = '%M:%d:%H:%m:%Y'

                           puts("Compiling templated instead of using cached Mustache...") if Uni_App.development?
                          
                           klass_name = "#{disguise}_In_Disguise"
                           require( "middleware/#{klass_name}"  )
                           disguise_class = eval(klass_name)
                           disguise_class.compile_all(file_name)

                           Mustache::Generator.new.compile(
                             Mustache::Parser.new.compile(
                               disguise_class.compile( original ).to_s 
                             )
                           )
                         end

      require "views/#{file_name}.rb"
      view_class                       = Object.const_get(file_name)
      view_class.raise_on_context_miss = true
      ctx                              = Mustache::Context.new(view_class.new(self))
      eval(template_content, nil, file_name, 1)
    end

  end # === module Uni_Render

  helpers Uni_Render
  
end # === module Sinatra



