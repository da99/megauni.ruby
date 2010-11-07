# MAB   ~/megauni/templates/en-us/html/Clubs_hearts.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_hearts.sass
# NAME  Clubs_hearts

class Clubs_hearts < Base_View

  def css_file
    "/stylesheets/#{lang}/Clubs_hearts.css"
  end

  def title 
    'Formerly: Surfer Hearts'
  end

  def club
    app.the.club
  end
  
  def months
    %w{ 8 4 3 2 1 }.map { |month|
      { :text => Time.local(2007, month).strftime('%B %Y'),
        :href=>"/uni/hearts/by_date/2007/#{month}/" 
      }
    }
  end

  def public_labels
    raise "no longer allowed."
    @public_labels ||= Message.public_labels.map {|label| {:filename => label} }
  end
  
end # === Topic_bubblegum 
