class String

  def must_not_be_empty
    str = strip
    raise ArgumentError, "String can't be empty." if str.empty?
    str
  end

  def expand_path
    File.expand_path must_not_be_empty
  end

  def has_extension? s_or_sym
    ext = '.' + s_or_sym.to_s.must_not_be_empty.sub(/^\.+/, '')
    !!must_not_be_empty[/#{Regexp.escape(ext)}$/]
  end

  def replace_extension s_or_sym
    ext       = '.' + s_or_sym.to_s.must_not_be_empty.sub(/^\.+/, '')
    base_name = File.basename(must_not_be_empty)
    pieces    = base_name.split('.')
    case pieces.size
      when 1
        self + ext
      else
        pieces.pop
        self.sub(/#{Regexp.escape(base_name)}$/, pieces.join('.') + ext)
    end
  end

  def file_system_name
    file.path || directory.path
  end

  def directory?
		s = self.strip
    return false if s.empty?
		@directory_name ||= begin
													[ 
														s, 
														File.expand_path(s)
													].detect { |d_path|
														File.directory? d_path
													}
												end
		!!@directory_name
  end

  def directory
    @string_directory ||= begin
														if !directory?
															raise ArgumentError, "Needs to be a directory: #{inspect}"
														end
														String_as_Directory.new @directory_name
													end
  end
                          
  def file?
    return false if self.strip.empty?
    !![
      self,
      File.expand_path(self)
    ].detect { |f_path|
      File.file? f_path
    }
  end

  def file
    @string_as_file ||= String_as_File.new(self)
  end

  def camelize(first_letter_in_uppercase = :upper)
    s = gsub(/\/(.?)/){|x| "::#{x[-1..-1].upcase unless x == '/'}"}.gsub(/(^|_)(.)/){|x| x[-1..-1].upcase}
    s[0...1] = s[0...1].downcase unless first_letter_in_uppercase == :upper
    s
  end

  def camel_flat
    s = split('_').map(&:capitalize).join('_')
  end
  
end # === String

class String_as_Directory
	attr_reader :orig_path
	
	def initialize raw_str
		str = raw_str.strip
		path = File.expand_path(str)
		if str.empty? || !File.directory?(path)
			raise ArgumentError, "Must be a directory: #{str}"
		end
		@orig_path = path
	end
	
	def name 
		File.basename(orig_path)
	end
	
	def path
		orig_path
	end

	def exists?
		File.exists?(orig_path)
	end

  def up *args
    File.expand_path(File.join(path, '..', *args))
  end

  def down *args
    raise ArgumentError, "Unable to continue w/o arguments: #{args.inspect}" if args.empty?
    File.expand_path(File.join(path, *args))
  end
  
  def each_file &blok
    return nil if !path.directory?
    raise ArgumentError, "Block is needed." unless block_given?
    Dir.entries(path).each { |file_name|
      file_path = File.expand_path(File.join(path, file_name))
      blok.call(file_path) if File.file?(file_path)
    }
  end

  def ruby_files_wo_rb
    ruby_files false
  end

  def ruby_files w_extension = true
    
    Dir.entries(path).map { |file_name| 
        if file_name =~ /\.rb$/
          full_path = File.expand_path(File.join(path,file_name))
          w_extension ?
            full_path :
            full_path.sub(/\.rb$/i, '') 
        else
          nil
        end
      }.compact
    
  end	
	
  def relative *args
    File.join(path, *args).expand_path
  end
  
end # ======== String_as_Directory

class String_as_File

  attr_reader :orig_path

  def initialize str
		if str.directory?
			raise ArgumentError, "Already a directory: #{str.inspect}"
		end
		if !str.file?
			raise ArgumentError, "File does not exist: #{str.inspect}"
		end
    @orig_path = File.expand_path(str)
  end

	def exists?
		File.exists?(orig_path)
	end  
	
  def name
    File.basename(orig_path)
  end
  
  def path
    orig_path
  end

  def directory
    File.join(path, '..').expand_path.directory
  end

  def read
    File.read(orig_path)
  end
 
  def expand_path
    File.expand_path(orig_path)
  end 
	
  def rename_to file_name_or_path
    f_path = if File.basename(file_name_or_path) == file_name_or_path
							 File.join(File.dirname(path), file_name_or_path)
						 else
							 File.expand_path(file_name_or_path)
						 end
    if File.exists?(f_path) 
      if File.identical?(f_path, path)
        return f_path
      else
        raise ArgumentError, "File already exists: #{f_path.inspect}"
      end
    end
    File.rename path, f_path
    f_path
  end
  
  def create_alias *args
    new_file = File.join(*args).expand_path
    return new_file if File.exists?(new_file) && File.identical?(path, new_file)
    if File.exists?(new_file)
      raise ArgumentError, "File already exists: #{new_file.inspect}"
    end
    File.symlink(path, new_file)
    new_file
  end

  def relative *args
    File.join(path, '..', *args).expand_path
  end

end # ======== String_as_File
