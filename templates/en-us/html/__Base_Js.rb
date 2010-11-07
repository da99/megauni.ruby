require 'models/Js_Dsl'

module Base_Js

  def js &blok
    Js_Dsl.new(&blok).to_s
  end
  
  def js! &blok
    Js_Dsl.new {
      instance_eval &blok
      return_false
    }.to_s
  end

end # === module Base_Js
