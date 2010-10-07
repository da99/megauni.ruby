

class Member_Notifys

  include Couch_Plastic

  enable_timestamps
  
  make :something, :anything

  # ==== Authorizations ====
 
	class << self
	end # === self

  def allow_to? action, editor # NEW, CREATE
		case action
			when :create
				false
			when :read
				false
			when :update
				false
			when :delete
				false
		end
  end
	

  # ==== Accessors ====

  

end # === end Member_Notifys
