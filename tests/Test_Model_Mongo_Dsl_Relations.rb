
# === Custom Classes for Testing ===

class Cafe_Galaxy
  include Mongo_Dsl

  %w{ 
    title
    body
  }.each do |field|
    make field, :not_empty
  end

	has_many :ghosts, :Cafe_Galaxy_Employee do
		
		override_as :spirits do
			where :role, 'spirit'
		end
		
		override_as :fk_spirits do
			foreign_key :spirit_id
		end

		filter :fantoms do
			where :role, 'fantom'
		end
		
		filter :fk_fantoms do
			foreign_key :fantom_id
		end
		
		foreign_key :ghost_id
		
	end

  has_many :employees, :Cafe_Galaxy_Employee, :cafe_id do

    override_as :men do
      where :role, 'man'
    end

    filter :bosses do
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

	must 'update foreign key if specified after override is declared.' do
		ghosts  = Cafe_Galaxy.querys[:ghosts]
		spirits = Cafe_Galaxy.querys[:spirits]
		assert_equal ghosts.foreign_key, spirits.foreign_key
	end

	must 'not update foreign key in override if different.' do
		ghosts  = Cafe_Galaxy.querys[:ghosts]
		fk      = Cafe_Galaxy.querys[:fk_spirits]
		assert_not_equal ghosts.foreign_key, fk.foreign_key
	end
	
	must 'update foreign key if specified after filter is declared.' do
		ghosts  = Cafe_Galaxy.querys[:ghosts]
		fantoms = ghosts.filters[:fantoms]
		assert_equal ghosts.foreign_key, fantoms.foreign_key
	end

	must 'not update foreign key in filter if different.' do
		ghosts  = Cafe_Galaxy.querys[:ghosts]
		fk      = ghosts.filters[:fk_fantoms]
		assert_not_equal ghosts.foreign_key, fk.foreign_key
	end


	must 'have filters (sub-querys) with their own independent (:dup) selectors.' do
		emp     = Cafe_Galaxy.querys[:employees]
		bosses  = emp.filters[:bosses]

		assert_not_equal bosses.selector, emp.selector
	end

	must 'have overrides with their own independent (:dup) selectors' do
		emp     = Cafe_Galaxy.querys[:employees]
		men     = Cafe_Galaxy.querys[:men]

		assert_not_equal men.selector, emp.selector
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
    bosses_data = bosses.map { |rec| rec.data.as_hash }
    
    assert_equal bosses_data, cafe.find.employees.bosses.go!
  end
  
  # Example: 
  #   member.job_titles
  #   member.part_time_job_titles
  #
  must 'retrieve a list of relations based on another relation' do
    cafe = create_cafe
    create_employee(cafe, :role=>'boss')
    men = (0..2).to_a.map { |index|
      create_employee(cafe, :role => 'man' )
    }
    men_data = men.map { |record| record.data.as_hash }

    assert_equal men_data, cafe.find.men.go!
  end
	
end # === class _create


