module Butler_Dsl

  attr_reader :dir, :file

  def self.included new_class
    if !new_class.include?(Demand_Arguments_Dsl)
      new_class.send :include, Demand_Arguments_Dsl
    end
  end

  def if_dir_exists raw_dir, &blok
    if raw_dir.directory?
      @dir = raw_dir.directory_name
      instance_eval &blok
    end
  end

  def unless_dir_exists raw_dir, &blok
    must_not_be_file raw_dir
    return false unless raw_dir.directory?

    @dir = raw_dir.directory_name
    instance_eval &blok
  end

  def link_dir opts
    validate_hash opts do
      demand :from, :to
      allow :msg
    end

    validator_dir opts[:from]
  end

  def sym_link_file &blok
    demand_block blok
    dsl = Sym_Link_Dsl.new &blok
    demand_file_exists dsl.from

		if File.exists?(dsl.to)
			demand_sym_link_matches {
				from dsl.from
				to   dsl.to
			}
		else
			File.symlink( dsl.from, dsl.to )
		end

  end

end # === Butler_Dsl

class Sym_Link_Dsl
  attr_reader :from, :to
  def initialize &blok
    instance_eval &blok
  end

  def from *args
		return @from if args.empty?
    @from = File.join(*args)
  end

  def to *args
		return @to if args.empty?
    @to = File.join(*args)
  end
end # === Sym_Link_Dsl
