

div.content!  { 
  ul.faq {
  
    li {
      div.question "For Babies and up."
      div.answer {
        p 'The most important are: a multi-vitamin, Vitamin D3, and Vitamin C.'
        p {
          span "Go to: "
          a('LifeSpanNutrition.com', :href=>"http://www.lifespannutrition.com/")
          span ".  Under 'Product Search', there are menus. Use the one for 'Select Age Category'."
        }
      }
    }

    li {
      div.question 'SIDS (Sudden Infant Death Syndrome)'
      div.answer {
        span 'Buy: '
        a('E-book by Bill Sardi.', :href=>'http://www.naturalhealthlibrarian.com/ebook.asp?page=SIDS')
      }
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

