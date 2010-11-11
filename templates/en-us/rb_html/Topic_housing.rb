

div.content!  { 
  ul.faq {
  
    li {
      div.question "Mouse Traps (Ratones)"
      div.answer {
        ul.products {
          li {
            span 'Big: '
            a('d-CON Ultra Set Covered Mouse Trap', :href=>'http://www.amazon.com/d-CON-00027-Ultra-Covered-Mouse/dp/B000P9URDQ/')       
          }
          li {
            span 'Small: '
            a( 'ebay: d-con mouse trap 12', :href=>'http://shop.ebay.com/items/?_nkw=d-con+mouse+trap+12')
          }
        
        }
      }
    } # li

    li {
      div.question "Stop junk mail (Para Correo de Propaganda)"
      div.answer {
        ul.products {
          li {
            span "Mailstopper Tonic:"
            a('mailstopper.tonic.com', :href=>"http://mailstopper.tonic.com/")
          }
        }
      }
    } # li




  } # === ul
} # == div.content!



partial('__nav_bar')

