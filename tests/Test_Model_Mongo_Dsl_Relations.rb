
# === Custom Classes for Testing ===

class Cafe_Galaxy
  include Go_Mon::Model

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
    
    filter :women do
      where :role, 'woman'
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
  include Go_Mon::Model

  ROLES = %w{ boss man woman }
  make :cafe_id, :not_empty
  make :name, :not_empty
  make :role, [:in_array, ROLES ]
  make :planet_id, :not_empty
  
  belongs_to :planet, :Cafe_Planet

  class << self
    def create editor, new_raw_data
      super.instance_eval do
        demand :cafe_id, :name, :role, :planet_id
        save_create
      end
    end
  end # === class

  def allow_to? action, editor
    true
  end

end # === class

class Cafe_Planet 
  include Go_Mon::Model
  make :title, :not_empty

  has_many :employees, :Cafe_Galaxy_Employee

  class << self
    def create editor, new_raw_data
      super.instance_eval do
        demand :title
        save_create
      end
    end
  end # === class

  def allow_to? action, editor
    true
  end

end # === class

class Test_Model_Mongo_Dsl_Relations < Test::Unit::TestCase

  PLANET_IDS = [0,1,2].map { |index| 
    Cafe_Planet.create(
      nil, 
      { :title => "Something #{rand(1000)}" }
    ).data._id
  }
  
  def create_cafe
    Cafe_Galaxy.create(
      nil, 
      {:title=>'Something', :body=>rand(1000).to_s}
    )
  end
  
  def create_planet new_vals = {}
    Cafe_Planet.create(
      nil, 
      { :title => "Something #{rand(1000)}" }.update(new_vals)
    )
  end
  
  def create_employee cafe, new_data = {}
    default_data =  {
      :cafe_id => cafe.data._id,
      :name => "Mr. #{rand(1000)}",
      :role => Cafe_Galaxy_Employee::ROLES[rand(3)],
      :planet_id => PLANET_IDS[ rand(3) ]
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
  
  must 'grab relations from other relations: cafe.find.employees.women.grab(:planet).go!' do
    cafe = create_cafe
    planet = create_planet
    women = (0..2).to_a.map { |index|
      create_employee(cafe, :role=>'woman', :planet_id=>planet.data._id)
    }
    women_data = women.map { |record| record.data.as_hash } 
  
    assert_equal [planet.data.as_hash], cafe.find.employees.women.grab(:planet).go!
  end
  
  must 'grab relations from other relations using just the name: cafe.find.employees.planet.go!' do
    cafe = create_cafe
    planet_1 = create_planet
    planet_2 = create_planet
    
    roles = %w{ woman man }
    planet_ids = [ planet_1.data._id, planet_2.data._id ]
    
    (0..5).to_a.map { |index|
      create_employee(cafe, :role=>roles[rand(2)], :planet_id=>planet_ids[rand(2)])
    }
    
    wish = [ planet_1 , planet_2 ].map { |planet| planet.data.as_hash }
    
    assert_equal wish, cafe.find.employees.planets.go!
  end

  must 'return an initialized Mongo_Dsl model when using :go_first!' do
    emp_id = Cafe_Galaxy_Employee.db.collection.find_one()['_id']
    assert_equal Cafe_Planet, Cafe_Galaxy_Employee.find._id(emp_id).grab(:planet).go_first!.class
  end
  
  must( 'return an initialized model for :go_first! on a Class query:' + 
  ' Life.find.username(un).go_first!') do
    doc = Life.db.collection.find_one
    life = Life.find.username(doc['username']).go_first!
    assert doc['_id'], life.data._id
  end

  must 'be able to merge relations using a namespace: cafe.find.employees.merge(:planet, :title)' do
    cafe   = create_cafe
    planet = create_planet( :title             => 'Riven' )
    emp    = create_employee( cafe, :planet_id => planet.data._id)
    
    wish = [ emp.data.as_hash.dup.update( 'planet_title' => planet.data.title ) ]
    
    assert_equal wish, cafe.find.employees.merge(:planet).fields(:title).go!
  end
  
  must 'not search in other Models for relations. (aka implicit relations w/o merge/grab/etc.)' do
    err = assert_raise(NoMethodError) {
      planet = Cafe_Planet.new( Cafe_Planet.db.collection.find_one )
      planet.find.employees.planet.go!
    }
    assert_match( 
      /undefined method `planet' for #<Mongo_Dsl::/ , 
      err.message
    )
  end
  
  must 'allow searching relations based on where querys: cafe.find.planets.where(:title, "Riven").go!' do
    cafe = create_cafe
    planet_1 = create_planet( :title => 'Riven 1' )
    emp_1 = create_employee( cafe, :planet_id => planet_1.data._id )

    assert_equal emp_1, cafe.find.employees.where(:planet_id, planet_1.data._id ).go_first!
  end
  
  must 'allow searching relations based on dynamic fields querys: cafe.find.planets.title("Riven").go!' do
    cafe = create_cafe
    planet_1 = create_planet( :title => 'Riven 1' )
    planet_2 = create_planet( :title => 'Riven 2' )
    emp_1 = create_employee( cafe, :planet_id => planet_1.data._id )
    emp_2 = create_employee( cafe, :planet_id => planet_2.data._id )

    assert_equal emp_2, cafe.find.employees.planet_id( planet_2.data._id ).go_first!
  end

end # === class _create


