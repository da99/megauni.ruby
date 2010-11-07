require 'models/Delegator_Dsl'
require 'models/Sentry_Sender'

module BASE_MAB
  
  def guide txt, &blok
    div.section.guide do
      h3 txt
      blok.call
    end
  end

  def about header, body
    div.about {
      h3 { span header.m! }
      div.body body.m!
    }
  end
  alias_method :about_section, :about
  
  def about! &blok
    div.col.about! &blok
  end
 
  def publish! &blok
    div.col.publish! &blok
  end 
  
end # === module





