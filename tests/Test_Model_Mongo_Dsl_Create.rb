# === Custom Classes for Testing ===

class Cafe_Le_Roger
  include Mongo_Dsl

  %w{ 
    title
    teaser
    body
  }.each do |field|
    make field, :not_empty
  end

  make_psuedo 'big_body', :not_empty

  def self.create editor, new_raw_data
    super.instance_eval do
      demand :title, :teaser, :body
      ask_for :big_body
      save_create
    end
  end

  def allow_to? action, editor
    case action
    when :create
      true
    else
      false
    end
  end

end # === Cafe_Le_Roger

class Test_Mongo_Dsl < Test::Unit::TestCase

  must 'raise Invalid, with errors msg, if missing required field' do
    err = assert_raise Cafe_Le_Roger::Invalid do
      Cafe_Le_Roger.create nil, {}
    end

    assert_match( /is required/, err.message )
  end
  
  must 'set new field value using :must_be' do
    teaser = "My Teaser: #{rand(1000)}"
    doc = Cafe_Le_Roger.create(nil, {:title=>'My Title', :teaser=>teaser, :body=>'My Body'})
    assert_equal teaser, doc.data.teaser
  end

  must 'set new field value using :must_be!' do
    body = "My body #{rand(1000)}"
    doc = Cafe_Le_Roger.create(nil, {:title=>'My Title', :teaser=>'My Teaser', :body => body})
    assert_equal body, doc.data.body
  end

  must 'save field value to db using :must_be' do
    teaser = "My Teaser: #{rand(1000)}"
    doc = Cafe_Le_Roger.create nil, {:title=>'My Title', :teaser=>teaser, :body=>'My Body'}
    new_doc = Cafe_Le_Roger.by_id(doc.data._id)
    assert_equal teaser, new_doc.data.teaser
  end

  must 'save field value to db using :must_be!' do
    body = "My body #{rand(1000)}"
    doc = Cafe_Le_Roger.create nil, {:title=>'My Title', :teaser=>'My Teaser', :body => body}
    new_doc = Cafe_Le_Roger.by_id(doc.data._id)
    assert_equal body, new_doc.data.body
  end

  must 'not set fields to proto_fields' do
    assert_not_equal Cafe_Le_Roger.fields, Cafe_Le_Roger.psuedo_fields
  end

  must 'not set proto field value' do
    big_body = "   My body #{rand(1000)}   "
    doc      = Cafe_Le_Roger.create( nil, 
                { :title =>'My Title', 
                  :teaser =>'My Teaser', 
                  :body =>"Test body.", 
                  :big_body =>big_body
                })
    new_doc  = Cafe_Le_Roger.by_id(doc.data._id)
    assert_equal nil, new_doc.data.as_hash[:big_body]
  end

  must 'not save psuedo field value' do
    big_body = "My body #{rand(1000)}"
    values   = {:title=>'My Title', :teaser=>'My Teaser', :body => "The Body", :big_body => big_body}
    doc      = Cafe_Le_Roger.create nil, values
    new_doc  = Cafe_Le_Roger.by_id(doc.data._id)
    
    orig_keys = values.keys
    orig_keys.delete(:big_body)
    orig_keys = orig_keys + [:_id, :_rev, :data_model] 
    
    assert_equal doc.data.as_hash.keys.sort, new_doc.data.as_hash.keys.sort
  end
  
end # === class _create


