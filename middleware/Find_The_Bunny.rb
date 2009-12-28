class Find_The_Bunny

	def initialize new_app
		@app = new_app
	end

	def call new_env
		
		new_env['the.app.meta'] ||= {}
    http_meth = new_env['REQUEST_METHOD'].to_s
		
    results = The_App.controls.detect { |control|

      raw_pieces = new_env['PATH_INFO'].strip_slashes.split('/')

      pieces = if raw_pieces.empty?
                 [http_meth, 'list']
               else
                 [http_meth, raw_pieces].flatten
               end
      
      pieces.dup.inject([]) do |a_name_arr, segment|
        
        a_name_arr << pieces.shift.gsub(/[^a-zA-Z0-9]+/, '_')
        a_name = a_name_arr.join('_')
        
        if control.public_instance_methods.include?(a_name) &&
           control.instance_method(a_name).arity == pieces.size
          
					new_env['the.app.meta'][:controller]    = control
					new_env['the.app.meta'][:action_method] = a_name
					new_env['the.app.meta'][:action_name]   = (a_name['_'] ? a_name.split('_')[1,10].join('_') : a_name)
					new_env['the.app.meta'][:args]          = pieces
          break
        end

        a_name_arr

      end

			new_env['the.app.meta'][:controller]
    }

		if results
			@app.call new_env 
		else
			raise The_App::HTTP_404, "Not found: #{new_env['REQUEST_METHOD']} #{new_env['PATH_INFO']}"
		end

	end

end # === Find_The_Bunny
