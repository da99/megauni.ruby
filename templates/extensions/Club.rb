
module Ruby_To_Html::Club

  def loop_clubs list_name, &blok
    text(capture {
      loop list_name do 
        div.club {
          h4 {
            a('{{title}}', :href=>'{{href}}')
          }
          show_if 'teaser?' do
            div.teaser '{{teaser}}'
          end
          
          loop_messages 'messages', &blok
        }
      end
    })
  end

  def club_nav_bar filename
    
    file = File.basename(filename).sub('.rb', '')
    vals = [
      [/_filename\Z/   , 'Home'               , '']            ,
      [/_e\Z/          , 'Encyclopedia'       , 'e/']          ,
      [/_news\Z/       , 'News'               , 'news/']       ,
      [/_magazine\Z/       , 'Magazine'               , 'magazine/']       ,
      [/_fights\Z/     , 'Fights', 'fights/']     ,
      [/_qa\Z/         , 'Q & A'              , 'qa/']         ,
      [/_shop\Z/       , 'Shop'               , 'shop/']       ,
      [/_predictions\Z/, 'Predictions'        , 'predictions/'],
      [/_random\Z/     , 'Random'             , 'random/'],
      [/_thanks\Z/     , 'Thanks'             , 'thanks/']
    ]
    
    text(capture {
      
      ul.nav_bar.club_nav_bar! {
        vals.each { |trip|
          if file =~ trip[0]
            li.selected  { trip[1] }
          else
            li { a(trip[1], :href=>'{{club_href}}' + trip[2] ) }
          end
        }

        show_if 'logged_in?' do
          li { a('Log-out', :href=>'/log-out/') }
        end

        if_not 'logged_in?' do
          li { a('Log-in', :href=>'/log-in/') }
        end
        
        if_not 'logged_in?' do
          li { a('megaUNI.com', :href=>'/') }
        end
        
        show_if 'logged_in?' do
          li { a('My Lifes', :href=>'/lifes/') }
        end
      } # ul
      
    })
  end


  def pretension!
    div.pretension! {
      partial '__club_title'
    }         
  end
  

end # === module
