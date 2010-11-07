div.content!  { 

  p {
    span 'If you are looking for back pain supplements, check the '
    a('"Back Pain" section.', :href=>'/back-pain/')
  }

  ul.faq {
  
    li {
      div.question %~ Rhumatoid Arthritis (dolor de articulaciones en las manos), 
        Cancer, Heart (corazon), energy
      ~
      div.answer {
        p 'Omega-3 fish oil (aceite de pescado) 1000 mg 3-4 times a day. '
        p 'Take it with food or else you might get very nauseous. '
        p "Don't take ASPIRIN, ibuprofen, Tylanol, Advil, etc., or your blood will become too watery."
        ul.products {
          li {
            p.title "Super Omega-3 Carlson Laboratories – 130 (capsules/pastillas) – (2 bottles)"
            p {
              span "$13 - "
              a( "LuckyVitamin.com", :href=>'http://www.luckyvitamin.com/')
              span "– 888-635-0474 – UPS or USPS (correo postal)"
            }
            p "(or buy the store brand in your local big-chain pharmacy like Eckerd's, Rite Aid, CVS, etc.)"
          }
        }
      }
    }
    
    li {
      div.question 'OSTERO-ARTHRITIS (dolor de rodilla)'
      div.answer {
        p {
          span 'For full info., buy this e-book: '
          a('Hyaluronic Acid by Bill Sardi.', :href=>'http://www.naturalhealthlibrarian.com/ebook.asp?page=Hyaluronic%20Acid')
        }
        p %~ 50 mg – 100 mg hyaluronic acid.~
        p %~ Much more effective than glucosamine and chondroitin. ~
        p %~ For best results, drink water 3 or more times a day. Also helps for skin and eyes. ~ 
        p "Don't take with blood thinners like aspirin, Advil, Tylenol, NSAIDs, etc. "
        p "Most of the pain should go away in 2 weeks."

        
        ul.products {
          li {
            p.title "Source Naturals Hyaluronic Joint Complex "
            p 'This is the most effective.'
            p "$30 – 120 tablets - Amazon.com – Free Shipping "
            p "$15 – 60 tablets - LuckyVitamin.com – 888-635-0474 – UPS or USPS (correo postal) "
          
          }
          li {
            p.title "Source Naturals Skin Eternal Hyaluronic Acid"
            p "Vitamin Shoppe or GNC - $10 – 60 tablets."
            p "Buy this one if you are in a hurry. This is the second best."
          }
        }
      }
    }



  } # === ul
} # == div.content!



partial('__nav_bar')

