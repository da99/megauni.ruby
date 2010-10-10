

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

  desc "Run one test file. 
        name= 
        ('tests/tests_' and '.rb' is automatically added.)
        warn= True"
  task :file do
    file_name    = ENV['name'].sub(/\ATest_/, '')
    use_debugger = ENV['debug']
    exec_name    = use_debugger ? 'rdebug' : 'ruby'
    warn         = !ENV['warn'] ? '-w' : ''
    sh(%~ #{exec_name} #{warn} -r "tests/__helper__" "tests/Test_#{file_name}.rb"~)
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



__END__
module FeFe_Test
  
  

  def self.results
    @count ||= 0
    @count_passed ||= 0
    @count_failed ||= 0
    [@count, @count_passed, @count_failed ]
  end

  def self.count
    @count ||= 0
  end

  def self.add_count
    @count ||=0
    @count += 1
  end

  def self.add_passed_count
    @count_passed ||= 0
    @count_passed+=1
  end

  def self.add_failed_count
    @count_failed ||= 0
    @count_failed += 1
  end

  def self.inspect_test raw_num = nil
    if raw_num
      @inspect_test = raw_num.to_i
    else
      @inspect_test ||= nil
    end
  end

  def self.inspect_test?
    @inspect_test && @count == @inspect_test
  end

  def self.inspection?
    !!inspect_test
  end

  def self.included new_class
    new_class.send :extend, Class_Methods
  end
  
  module Class_Methods
    
    
    def set_counter new_count
      @count = 0
    end

    def add_count
      FeFe_Test.add_count
    end

    def it title, &blok
      add_count
      
      if FeFe_Test.inspection? && !FeFe_Test.inspect_test?
        return false
      end

      f_unit = new(title, FeFe_Test.count, before, after )
      
      f_unit.run blok
    end
    
    def before &blok
      if block_given?
        @before = blok
      else
        @before ||= nil
      end
    end
    
    def after &blok
      if block_given?
        @after = blok
      else
        @after ||= nil
      end
    end

    def context title
      if FeFe_Test.inspection? 
        return false
      end 
      @context = title
      puts ' *' * 19
      puts ' CONTEXT: ' + title
      puts ''
    end

    def total_tests
      @count
    end
    
  end # ======== Class_Methods
  
  def initialize title, count, before, after
    
    @title  = title
    @count  = count
    @before = before
    @after  = after
      
  end

  def run body
    if @before
      instance_eval( &@before )
    end
    
    @results = begin
      
      if FeFe_Test.inspection? && FeFe_Test.inspect_test?
        
      end

      instance_eval( &body )
      [ true, "ok" ]
    rescue Object => e
      [ false, e.message, e ]
    end

    if @after
      instance_eval( &@after )
    end
    
    if @results.first
      FeFe_Test.add_passed_count
      puts "  ok   : #{@count}: #{@title}" 
    else
      FeFe_Test.add_failed_count
      puts ''
      puts_red "  FAIL: #{@count}: #{@title}"
      puts_white "  #{@results[2].class}: #{@results[1]} "
      if !@results[2].backtrace.first['on_assertion_exit']
        @results[2].backtrace.each { |l|
          puts l  if (!l['lib/ruby/gems'] && !l['lib/ruby/site_ruby'] && !l['bin/fefe'] && !l['fefe/tasks'])  || (@results[2].backtrace.index(l) < 2)
          # if l[FeFe_The_French_Maid::Prefs::PRIMARY_APP] &&   !l['instance_eval'] && !l['__fefe']
        }
      end
      puts ''
    end

  end

end # ======== FeFe_Test

