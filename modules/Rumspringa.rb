
module Rumspringa
  
  def rumspringa meth_name, mod
    module_eval %~
      def #{meth_name} &blok
        clone = self.clone
        clone.extend #{mod}
        clone.instance_eval( &blok )
      end
    ~
  end

end
