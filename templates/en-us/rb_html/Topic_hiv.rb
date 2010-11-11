

div.content!  { 
  ul.faq {
  
    li {
      div.question 'Quercetin - For all adults.'
      div.answer {
        p "This is the most important. Take it with food."
        p {
          span "But it at a pharmacy or online: "
          a("$12 - LuckyVitamin", :href=>'http://www.luckyvitamin.com/item/itemKey/57297')
        }
      }
    }

    li {
      div.question 'Allicin (Garlic Extract)'
      div.answer {
        p "More effective than penicillin."
        p {
          span "Real Garlic by Purity Products: "
          a('http://www.lifespannutrition.com/products.asp?itemnumber=190', :href=>"http://www.lifespannutrition.com/products.asp?itemnumber=190")
        }
      }
    }

    li {
      div.question "Longevinex"
      div.answer {
        p "For adult males and non-menstruating (e.g. post-menopausal) females only."
        p "Avoid all medications and drugs. Including: aspirin, Advil, Tylenol, etc."
        p "For best results, take at a later time than Vitamin C."
        p {
          a("Longevinex.com", :href=>"http://www.longevinex.com/")
          span " - (866) – 405-4000 – $37 (1 box),  $120 (4 boxes) "
        }
      }
    }

    li {
      div.question "Vitamin D3 + Magnesium Citrate"
      div.answer {
        p 'LifeSpanNutrition.com – (800) 247-5731 (correo postal)'
        p '$15 - "30 Minutes of Sunshine"'
      }
    }

    li {
      div.question "Omega-3  fish oil - 1000 mg 3-6 times a day"
      div.answer {
        p "This is an oil, so take it with food or else you might get very nauseous."
        p "Buy a decent brand in your local big-chain pharmacy like Eckerd's, CVS, etc." 
        p "Take it 3-6 times a day, 2 or more gelcaps a day."
      }
    }



  } # === ul
} # == div.content!



partial('__nav_bar')

