

class Member_Reposts

  include Couch_Plastic

  enable_timestamps
  
  make :body, :anything

  # ==== Authorizations ====
 
	class << self
	end # === self

  def allow_to? action, editor
		case action
		when :create
			false
		when :read
		when :update
		when :delete
		end
  end

  # ==== Accessors ====

  

end # === end Member_Reposts
