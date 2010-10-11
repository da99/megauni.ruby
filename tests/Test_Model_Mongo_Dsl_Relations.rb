
# === Custom Classes for Testing ===

class Cafe_Galaxy
  include Mongo_Dsl

  %w{ 
    title
    body
  }.each do |field|
    make field, :not_empty
  end

  has_many :employees, :Cafe_Galaxy_Employee, :cafe_id do

    filter :bossess do
      where :role, 'boss'
    end
    
  end

  class << self
    def create editor, new_raw_data
      super.instance_eval do
        demand :title, :body
        save_create
      end
    end
  end # === class

  def allow_to? action, editor
    case action
    when :create
      true
    else
      false
    end
  end

end # === Cafe_Galaxy

class Cafe_Galaxy_Employee
  include Mongo_Dsl

  ROLES = %w{ boss man woman }
  make :cafe_id, :not_empty
  make :name, :not_empty
  make :role, [:in_array, ROLES ]
  
  class << self
    def create editor, new_raw_data
      super.instance_eval do
        demand :cafe_id, :name, :role
        save_create
      end
    end
  end # === class

  def allow_to? action, editor
    true
  end

end # === class

class Test_Model_Mongo_Dsl_Relations < Test::Unit::TestCase

  def create_cafe
    Cafe_Galaxy.create(
      nil, 
      {:title=>'Something', :body=>rand(1000).to_s}
    )
  end
  
  def create_employee cafe, new_data = {}
    default_data =  {
      :cafe_id => cafe.data._id,
      :name => "Mr. #{rand(1000)}",
      :role => Cafe_Galaxy_Employee::ROLES[rand(3)]
    }
    data = default_data.update(new_data)
    
    Cafe_Galaxy_Employee.create(
      nil,
      data
    )
  end

  must 'retrieve list of relations: cafe.employees!' do
    cafe = create_cafe
    emps = [ create_employee(cafe), 
             create_employee(cafe),
             create_employee(cafe) ]
    emps_data = emps.map { |obj| obj.data.as_hash }
    
    assert_equal emps_data, cafe.employees!
  end
  
  must 'retrieve a sub list of relations: cafe.find.employees.bosses.go!' do
    cafe = create_cafe
    man  = create_employee(cafe, :role => 'man')
    bosses =  (0..3).to_a.map { |index| 
      create_employee(cafe, :role=>'boss')
    }
    bossess_data = bosses.map { |rec| rec.data.as_hash }
    
    assert_equal bossess_data, cafe.find.employees.bossess.go!
    
  end
  
end # === class _create


