class Club_Control_Base_View < Base_View

  def club
    app.the.club
  end

  def club_teaser
    app.the.club.data.teaser
  end

  def club_filename
    app.the.club.data.filename
  end
  
end
