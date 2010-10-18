
class Gather
  attr_reader :meths

  def initialize &blok
    @meths = []
    instance_eval(&blok) if block_given?
  end

  def method_missing name, *args, &blok
    meths << [name, args, blok && Gather.new.instance_eval( &blok )]
    self
  end
  
end

