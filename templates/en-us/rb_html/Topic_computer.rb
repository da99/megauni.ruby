

div.content!  { 
  ul.faq {
  
    li {
      div.question "Printer: Brother DCP-585CW"
      div.answer {
        p 'Includes scanner.'
        p {
          span 'Read reviews: '
          a('http://www.newegg.com/Product/Product.aspx?Item=N82E16828113342&Tpk=Brother%20DCP-585CW', :href=>"http://www.newegg.com/Product/Product.aspx?Item=N82E16828113342&Tpk=Brother%20DCP-585CW")
        }
      }
    }

    li {
      div.question "Inspiron 15 or Inspiron 17"
      div.answer {
        p {
          a('http://www.dell.com/home/laptops', :href=>'http://www.dell.com/home/laptops')
        }
        p 'Upgrade memory to: 4 GB'
        p 'Upgrade battery to: 9-cell lithium battery'
        p 'For Inspiron 15, upgrade HD display to: 15.6" High Definition+ (1600x900) LED Display with TrueLife' 
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

