# VIEW ~/megauni/views/Hello_salud.rb
# SASS ~/megauni/templates/en-us/css/Hello_salud.sass
# NAME Hello_salud

div(:id=>"about_me") {
  p {
    span "Below is a list of my favorite products."
  }
}
    
div.revols(:id=>"health") {

  h2 "Salud (Health)"
  p { 
    span 'No tome Aspirina.'
    a('Mas detailes.', :href=>"http://www.lewrockwell.com/spl/prevent-heart-attack-or-stroke.html")
  }
  p 'Longevinex - (866) 405-4000'
  ul {        
    li {
      a( :href=>"http://www.longevinexadvantage.com" ) { 'Longevinex Advantage' } 
      br
      span ' - Nueva formula.'
    }
  }
  
  p {
    span 'Life Span Nutrition - (800) 247-5731 '
  }
  
  ul {
    li {
      span( 'Web Address:' )
      a(:href=>'http://www.LifeSpanNutrition.com/') { 'LifeSpanNutrition.com' }
    }
    li {
      a( :href=>"http://www.lifespannutrition.com/products.asp?itemnumber=660" ) { "30 Minutes of Sunshine" }
      br 
      span ' - 3 botellas - $30 - Vitamin D3 with Magnesium Citrate.'
    }
    

    
    li {
      a( :href=>"http://www.lifespannutrition.com/products.asp?itemnumber=67") { "Perfect Multi Super Greens "}
      br 
      span ' - $33 - 120 pastillas '
    }
  }
  
  p {
    span 'Lucky Vitamin - 888-635-0474 - '
  }
  ul {
    li {
      span( 'Sitio:' )
      a(:href=>'http://www.luckyVitamin.com/') { 'LuckyVitamin.com' }
    }     
    li {
      a( :href=>"http://www.luckyvitamin.com/item/itemKey/69152" ) { 'Source Naturals Hyaluronic Joint Complex' }
      br 
      span ' - $15 - 60 pastillas - Osteo-arthritis knee pain (dolor de rodilla).'
    }   
    li {
      a( :href=>'http://www.luckyvitamin.com/item/itemKey/53515' ) { 'NAC' } 
      br 
      span 'Para el ligado. Tome con la Vitamina C. (For the liver. Take it with Vitamin C.)'
    }
    li {
      a( :href=>"http://www.luckyvitamin.com/item/itemKey/59157") { 'Super Omega-3 Carlson' }
      br 
      span ' - $13 - 130 pastillas'
    }  

    li {
      a(:href=>"http://www.luckyvitamin.com/item/itemKey/56415") { 'Forti-Flax' } 
      br 
      span ' - $6 - (polvo de linaza)'
    }
    
    li {
      span 'Flaxseed alternative: '
      a(:href=>"http://www.luckyvitamin.com/item/itemKey/58713") { 'Brevail' } 
      br 
      span ' - $14 - 30 pastillas - (extracto de linaza)'
    }       
    
    li {
      a( :href=>"http://www.luckyvitamin.com/item/itemKey/67144") { 'Source Naturals IP-6' }
      br
      span ' - $10 - 90 pastillas - (Usa esto cuando tiene tumores. Estomago vacilo, con agua, no tome otra vitamina o comida hasta 2 horas antes y despues.)'
    }
    

    
    li {
      span { 'Stevia Sweetener for Diabetics' }
      a(:href=>'http://www.luckyvitamin.com/item/itemKey/70095') { "Wisdom Natural Brands - SweetLeaf Stevia Plus - 100 Packet(s)" }
    }
    
    li {
      span { 'Stevia Sweetener - (Cheaper, but good)' }
      a(:href=>'http://www.luckyvitamin.com/item/itemKey/75705') { "NOW Foods - Non-Bitter Stevia Extract Certified Organic - 100 Packet(s)" }
    }
  }
  
  p {
    span 'Books (Libros en Ingles)'
  }
  
  ul {
    li {
      a( :href=>"http://www.thecancerbook.com" ) { 'You Don\'t Have to Be Afraid of Cancer Anymore' }
      br
      span " - (El libro de cancer) - 500+ pages - (800) 247-5731"
    }
    li {
      a( :href=>"http://www.naturalhealthlibrarian.com/" ) { 'Natural Health Librarian' }
      br 
      span "E-books. (Libros digitales)"
    }       
  }
  

  
  p { span 'Stevia Extract' }
  
  ul {
    li {
      span 'Marka: '
      a(:href=>'http://www.truviastore.com/') { 'Truvia' }
      br 
      span 'Super-market or '
      a(:href=>'http://www.truviastore.com/') { 'online.' }
    }
  }
  

} # div.revols

div.revols(:id=>"soap") {
  h2 "Jabon (Soap)"
  
  ul {
    li {
      span {'Shampoo and Body/Hand Wash'}
      a( :href=>"http://www.luckyvitamin.com/item/keyword/black+soap/itemKey/61865" ) { 'Dr. Woods Black Soap' }
    }
    
    li {
      span { 'Shampoo' }
      a(:href=>'http://www.luckyvitamin.com/item/itemKey/75203') { "Kirk's Natural - Original Coco Castile" }
    }     
  
  }
  
  h2 "Dietes (Teeth)"

  ul {
    li {
      span 'Non-Flouride Toothpaste'
      a( :href=>"http://www.luckyvitamin.com/item/itemKey/53785" ) {'Now XyliWhite Toothpaste Gel'}
    }

    li {
      span 'Vitamin D3'
      a( :href=>"http://www.lifespannutrition.com/products.asp?itemnumber=660" ) { "30 Minutes of Sunshine" }
    }

  }

  h2 "Inflation (Economia)"
  
  ul {
    li {
      span {'Prices continue to slowly climb. Here is one possible solution:'}
      a( 'Bullion Vault', :href=>"http://www.bullionvault.com/" ) 
    }
    li {
      span 'This article explains gov\'t (local/state/federal) is taking 50% of wealth out of the economy:'
      a( 'Bank on Inflation', :href=>'http://www.atimes.com/atimes/Global_Economy/KH14Dj01.html' )
    }
  }     
  
}

div.revols(:id=>"home") {
  h2 "Para La Casa (Home)"
  
  
  p { span 'Mouse Traps (Ratones)' }
  
  ul {
    li {
      span 'Big:'
      a(:href=>'http://www.amazon.com/d-CON-00027-Ultra-Covered-Mouse/dp/B000P9URDQ/') { "d-CON Ultra Set Covered Mouse Trap" }
    }
    li {
      span 'Small:'
      a(:href=>'http://shop.ebay.com/items/?_nkw=d-con+mouse+trap+12') { 'ebay: d-con mouse trap 12' }
    }
  }
  
  p { span 'Para Correo Propaganda (Stop junk mail)' }      
  
  ul {
    li {
      span( 'Mailstopper Tonic:' )
      br
      a( 'mailstopper.tonic.com', :href=>'http://mailstopper.tonic.com' )
      br 
      span "El sitio es ingles solamenta. (English only site.)"
    }
  }
  
  p { span 'Telefono (Cellular)' }
  
  ul {
  
    li {
      span('No Contract - $50 after taxes - Unlimited Night/Weekend')
      br 
      a( 'Individual 600 with FlexPay', :href=>'http://www.t-mobile.com/shop/plans/cell-phone-plans-detail.aspx?tp=tb1&rateplan=Individual-600-with-FlexPay-Monthly' )
    }
    
    li {
      span('No Contract - $60 after taxes - Unlimited Night/Weekend')
      br 
      a( 'Individual 1000 Plus with FlexPay', :href=>'http://www.t-mobile.com/shop/plans/cell-phone-plans-detail.aspx?tp=tb1&rateplan=Individual%201000%20Plus%20with%20FlexPay%20Monthly' )
      br 
      span('Make sure it says "1000 Plus".' )
    }
    li {
      span 'Choose EasyPay (recurring credit card billing) to avoid $5 fee each month.'
    }
  }
  
}
