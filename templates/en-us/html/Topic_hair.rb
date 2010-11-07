


div.content!  { 

  p 'Most shampoos and soaps in pharmacies and super-markets containt SLS (sodium lauryl sulfate).'
  p 'SLS is bad for skin and hair. Get all your soap/shampoo at vitamin stores and health shops.'
  p {
    span 'Read more on why you should'
    a('avoid major-brand shampoos and soaps.', :href=>'http://www.google.com/search?q=hair+loss+%22sodium+lauryl+sulfate%22')
  }

  p 'Below is a list of safe and natural soaps and shampoos available at Amazon.com and health stores.'
  
  ul.faq {
  
    li {
      div.question "Body/Hands/Face"
      div.answer {
        a('Dr. Woods Black Soap', :href=>"http://www.luckyvitamin.com/item/keyword/black+soap/itemKey/61865")
      }
    }

    li {
      div.question 'Shampoo'
      div.answer { 
        a('Kirk\'s Natural - Original Coco Castile', :href=>"http://www.luckyvitamin.com/item/itemKey/75203")
      }
    }

    li {
      div.question 'Bar Soap'
      div.answer {
        a('Kirk\'s Natural - Bar', :href=>"http://www.luckyvitamin.com/item/itemKey/75211")
      }
    }


  } # === ul
} # == div.content!



partial('__nav_bar')

