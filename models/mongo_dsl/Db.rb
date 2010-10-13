require 'models/Delegator_Dsl'

class Mongo_Dsl::Db_Class
  
  attr_reader :target, :cache

  def initialize target
    @target = target
    @cache = {}
  end
  
  def name
    cache[:name] ||= target.name + 's'
  end

  def collection
    cache[:collection] ||= DB.collection(name)
  end

end # === class Mongo_Dsl::Db_Class


class Mongo_Dsl::Db_Instance

  extend Delegator_Dsl
  delegate_to :db_klass, :name, :collection

  attr_reader :target, :db_klass

  def initialize target
    @target   = target
    @db_klass = target.class
  end 

end # === class Mongo_Dsl::Db_Instance

