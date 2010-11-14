

namespace :tests do

  desc %! Runs tests for your app using glob: tests/test_*.rb 
  GEM_UPDATE = false!
  task :all do
    
    if ENV['GEM_UPDATE']
      puts_white 'Updating gems...'
      puts_white shell_out('gem update')
    end
    
    ENV['RACK_ENV'] ||= 'test'
    Rake::Task['db:reset!'].invoke
    rb_files = Dir.glob('tests/Test_*.rb').sort.reverse.map { |file| file.sub('.rb', '')}
    
    order    = [ 'Helper', 'model_Mongo_Dsl' ]
    pre      = order.inject([]) { |m,pat| m + rb_files.select {|file| file =~ /_#{pat}/ }  }
    ordered  = (rb_files - pre) + pre.reverse
    
    require "tests/__helper__"

    ordered.each { |file|
      require file 
    }

  end # ======== :run

  desc %~ 
    Run one test file. 
        name= 
        ('tests/tests_' and '.rb' is automatically added.)
        warn    = True
        compile = True
  ~.strip
  task :file do
    file_name    = ENV['name'].sub(/\ATest_/, '')
    ENV['compile'] ||= true
     
    do_compile = ENV['name']['Control_'] && ENV['compile'] == true
    if do_compile
      pieces = file_name.to_s.split('_')
      pieces.shift
      sh "rake views:compile name=\"*#{pieces.first}*\""
    end

    use_debugger = ENV['debug']
    exec_name    = use_debugger ? 'rdebug' : 'ruby'
    warn         = !ENV['warn'] ? '-w' : ''
    Dir.glob( "tests/Test_#{file_name}.rb" ).each { |path| 
      sh %~ 
         #{exec_name} #{warn} -r "tests/__helper__" "#{path}"
      ~.strip
    }
  end
  
  desc "Creates a test file. Uses: 
    type=[control|model|...] 
    name=[Ruby Object] 
    action=[create|update|...]
    file=[none|original file path|default]"
  task :create do
    model_type = ENV['type'].strip.capitalize
    ruby_obj   = ENV['name'].strip
    action     = ENV['action'] && ENV['action'].strip.capitalize
    
    name = "Test_" + [model_type, ruby_obj, action].compact.join('_')

    original_file = case ENV['file'] 
                    when nil 
                      if %w{ Control Model }.include?(model_type)
                        original_file = "#{model_type.downcase.sub(/s\Z/, '')}s/#{ruby_obj}.rb"
                      end
                    else
                      ENV['file'].strip
                    end 

    original_file_paste = original_file ? "# #{original_file}" : ''

    if model_type == 'Control'
      original_file_paste += "\nrequire 'tests/__rack_helper__'"
    end

    file_path = "tests/#{name}.rb"
    if File.exists?(file_path)
      raise "File may not be overwritten: #{file_path.inspect}"
    end

    content = File.read("tests/__template__.txt").
                gsub("{{name}}", name).
                gsub("{{file}}", original_file_paste)
    
    File.open(file_path, 'w') do |file|
      file.puts content
    end

    puts_white "Created:"
    puts file_path
  end
  
    
end # ======== Tests


