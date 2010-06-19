# MAB   ~/megauni/templates/en-us/mab/Clubs_by_id.rb
# SASS  ~/megauni/templates/en-us/sass/Clubs_by_id.sass
# MODEL ~/megauni/models/Club.rb
# CONTROL ~/megauni/controls/Clubs.rb
# NAME  Clubs_by_id

class Clubs_by_id < Base_View
 
  def mini_nav_bar?
    true
  end
  
  def months
    %w{ 8 4 3 2 1 }.map { |month|
      { :text => Time.local(2007, month).strftime('%B %Y'),
        :href=>"/clubs/hearts/by_date/2007/#{month}/" 
      }
    }
  end

  def public_labels
    @public_labels ||= Message.public_labels.map {|label| {:filename => label} }
  end

  def messages_latest
    @cache['results.messages_latest'] ||= compile_messages(app.env['results.messages_latest'])
  end
  
end # === Clubs_by_id 
