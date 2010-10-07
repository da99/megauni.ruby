

class Failed_Log_In_Attempts

  TooManyFailedAttempts = Class.new( StandardError )
	
  include Couch_Plastic
  MAX = 4
	
  enable_timestamps
  
	make :owner_id,   :mongo_object_id
	make :username,   :anything
	make :date,       :anything
	make :time,       :anything
	make :ip_address, :anything
	make :user_agent, :anything

	# ==== Class Methods  ====
	
	class << self

		def log_failed_attempt( ip_address )

			params = { :ip_address=>ip_address, :created_at=>utc_today }
			old_la = LogInAttempt.filter(params).first
			
			return LogInAttempt.create( params ).total if !old_la
		 
			# Why use ".this.update"? Answer: http://www.mail-archive.com/sequel-talk@googlegroups.com/msg02150.html
			old_la.this.update :total => 'total + 1'.lit
			new_total = old_la[:total] + 1  

			if new_total >= MAX
					raise TooManyFailedAttempts,  "#{new_total} log-in attemps for #{old_la.ip_address}"
			end
			
			new_total

		end # === def self.log_failed_attempt

		def too_many?(ip_address)
			old_la = LogInAttempt.where(:ip_address=>ip_address, :created_at=>utc_today).first
			return false if !old_la
			old_la[:total] >= MAX
		end
		
		def utc_today
			Time.now.utc.strftime("%Y-%m-%d")
		end
		
	end # ===

  # ==== Authorizations ====
	 
	class << self
		def create editor, raw_raw_data
			new do
				self.manipulator = editor
				ask_for :owner_id, :username, :date, :time, \
								:ip_address, :user_agent
				save_create
			end
		end
	end
 
	def allow_to? action, editor
		case action
		when :create
			true
		when :read
			false
		when :update
			false
		when :delete
			false
		end
	end

	
  # ==== Accessors ====

  

end # === end Failed_Log_In_Attempts
