
class Dyno_Cache

	def initialize
		@the_cache = {}
	end

	def method_missing name, *vals
		case vals.size
		when 0
			return super unless @the_cache.has_key?(name)
			@the_cache[name]
				
		when 1
			name_s = name.to_s
			return super unless name_s['=']
			name_get = name_s.sub('=', '').to_sym
			@the_cache[name_get] = vals.first
		else
			return super
		end
	end

end # === class
