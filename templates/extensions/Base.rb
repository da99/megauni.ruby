
module Ruby_To_Html::Base
  
  def a! txt, href
    a(txt.m!, :href=>href.m!)
  end
  
  def a_button txt, href
    a.button(txt.m!, :href=>href.m!)
  end
  
  def a_button! txt, href
    div.a_button {
      a.button(txt.m!, :href=>href.m!)
    }
  end

  def mustache mus, &blok
    if block_given?
      text "\n{{\##{mus}}}\n\n"
      yield
      text "\n{{/#{mus}}}\n\n" 
    else
      text "\n{{#{mus}}}\n\n"
    end
  end
  
  alias_method :show_if, :mustache
  alias_method :loop,    :mustache

  def if_not mus, &blok
    text "\n{{^#{mus}}}\n\n"
    yield
    text "\n{{/#{mus}}}\n\n" 
  end
  alias_method :if_no,    :if_not
  alias_method :if_empty, :if_not
  
  def javascript_files
    (@js_files ||= []).compact.uniq
    @js_files
  end

  def add_javascript_file file_hash_or_string
    case file_hash_or_string
    when String
      javascript_files << ({
        :src=>"#{file_hash_or_string}?#{Time.now.utc.to_i}" , 
        :type=>'text/javascript'
      })
    else
      javascript_files << file_hash_or_string
    end
  end

  def the_app
    @the_app = Class.new {
      def method_missing *args
        return self
      end
      def to_s
        ''
      end
    }.new
 
  end
  alias_method :app_vars, :the_app

  def partial( raw_file_name )
    calling_file = caller[0].split(':').first
    calling_dir  = File.dirname(calling_file)
    file_name    = File.expand_path(File.join(calling_dir,raw_file_name)).to_s
    file_name += '.rb' if !file_name['.rb']
    
    # Find template file.
    partial_filepath = if File.exists?(file_name)
       file_name 
    end

    if !partial_filepath
      raise "Partial template file not found: #{file_name}"
    end
    
    # Get & Render the contents of template file.
    text( 
      capture { 
        eval( File.read(partial_filepath), nil, partial_filepath, 1  )
      } 
    )
    ''
  end # === partial
  
  def to_one_line txt
    txt.split("\n").map(&:strip).join(' ')
  end
  
  def div_centered &blok
    div.outer_shell! {
      div.inner_shell! {
        div.centered {
          yield
        }
      }
    }
  end

  def nav_bar_li_selected txt
    text(capture {
      li.selected { span "< #{txt} >" }
    })
  end

  def nav_bar_li_unselected txt, href
    text(capture {
      li {
        a " #{txt} ", :href=>href
      }
    })
  end

  def nav_bar_li *args
    case args.size
    when 2, 3
      controller, raw_shortcut, txt = args
      shortcut      = raw_shortcut.gsub(%r!\A/|/\Z!,'').gsub(/[^a-zA-Z0-9\_]/, '_')
      template_name = "#{controller}_#{shortcut}".to_sym
      txt      ||= shortcut.to_s.capitalize
    when 4
      controller, action, raw_shortcut, txt = args
      template_name = "#{controller}_#{action}".to_sym
    end
    
    prefix = case controller
               when :Topic, :Topics
                 '/uni'
               else
                 ''
               end
                 
    href     = shortcut == 'home' ? '/' : File.join('/', prefix, raw_shortcut, '/')
    if self.template_name.to_s === template_name.to_s
      nav_bar_li_selected txt
    else
      nav_bar_li_unselected txt, href
    end
  end

  def nav_bar raw_shortcut, txt = nil
    shortcut = raw_shortcut.gsub(/[^a-zA-Z0-9\_]/, '_')
    path = shortcut == 'home' ? '/' : "/#{raw_shortcut}/"
    txt ||= shortcut.to_s.capitalize
    text(capture {
      mustache "selected_#{shortcut}" do
        li.selected { span txt }
      end
      mustache "unselected_#{shortcut}" do
        li {
          a txt, :href=>"#{path}"
        }
      end
    })
  end

  def guide txt, &blok
    div.section.guide do
      h3 txt
      blok.call
    end
  end

  def about header, body
    div.about {
      h3 { span header.m! }
      div.body body.m!
    }
  end
  alias_method :about_section, :about
  
  def about! &blok
    div.col.about! &blok
  end
 
  def publish! &blok
    div.col.publish! &blok
  end 
  
end # === module
