# MAB   ~/megauni/templates/en-us/html/Clubs_by_filename.rb
# SASS  ~/megauni/templates/en-us/css/Clubs_by_filename.sass
# MODEL ~/megauni/models/Club.rb
# CONTROL ~/megauni/controls/Clubs.rb
# NAME  Clubs_by_filename

require 'views/extensions/Base_Club'

class Clubs_by_filename < Base_View
 
  include Views::Base_Club

  delegate_to :club, %w{
    href_follow
    href_delete_follow
    href_delete
    href_members
    href_edit
  } 

  def mini_nav_bar?
    true
  end
  
  def months
    %w{ 8 4 3 2 1 }.map { |month|
      { :text => Time.local(2007, month).strftime('%B %Y'),
        :href=>"/uni/hearts/by_date/2007/#{month}/" 
      }
    }
  end

  def public_labels
    raise "No longer allowed."
    @public_labels ||= Message.public_labels.map {|label| {:filename => label} }
  end

  def messages_latest
    compile_and_cache( 'messages.latest' , app.the.latest_messages )
  end

  def club_teaser
    if club.is_a?(Life) && !club.data.teaser
      "The personal space of a member called: #{club_filename}."
    else
      super
    end
  end

  def memberships?
    !all_memberships.empty?
  end

  def all_memberships
    return []
    [ 
      {'privacy' => 'public', 'title' => 'Editor', 'href' => '/none', 'name'=>'Jacqutii'},
      {'privacy' => 'public', 'title' => 'Reader', 'href' => '/none', 'name'=>'Roger'},
      {'privacy' => 'private', 'title' => 'Creator', 'href' => '/none', 'name'=>'Jean-Claude'},
    ]
  end
  alias_method :owner_memberships, :all_memberships

  def public_memberships
    @public_mems ||= all_memberships.select { |mem| 
      mem['privacy'] == 'public' 
    }
  end
  Club::MEMBERS.each { |ring|
    alias_method :"#{ring}_memberships", :public_memberships
  }

  def following
    false
  end
  
  def follows
    []
  end

  def notifys
    []
  end

end # === Clubs_by_filename
