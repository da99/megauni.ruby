# /home/da01/megauni/templates/en-us/html/Account_list.rb
class Account_list < Base_View

  def title 
    'My Account'
  end

  def lifes
    @app.current_member.data.lifes.map { |life_cat, life|
      { :category => life_cat,
        :username => life[:username]}
    }
  end

end

