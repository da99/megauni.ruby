

div.content!  { 
  ul.faq {
  
    li {
      div.question "Can you shrink and kill tumors?"
      div.answer {
        'Of course you can. Don\'t expect your doctor to help. '
      }
    }

    li {
      div.question "Book: 'You don't have to worry about Cancer Anymore' by Bill Sardi"
      div.answer {
        a('http://www.thecancerbook.com/', :href=>'http://www.thecancerbook.com/')
        span " 500 pages with research citations. "
      }
    }

    li {
      div.question 'E-books:'
      div.answer {
        ul.products {
          li {
            a('Iron & IP-6', :href=>'http://www.naturalhealthlibrarian.com/ebook.asp?page=Iron%20Overload')
          }
          li {
            a('Resveratrol (Red Wine Molecule)', :href=>'http://www.naturalhealthlibrarian.com/ebook.asp?page=Resveratrol%20Wine%20Pill')
          }
        }
      }
    }

    li {
      div.question "Longevinex - (Benefits of red wine with no sugar/alcohol.)"
      div.answer {
        p "For tumors, cancer, eyes, energy, brain/memory, bones, sleep, diabetes, rheumatoid arthritis... almost everything. Combine this with '30 Minutes of Sunshine' (see 'Cold/Flu' section) for the best anti-aging combo. "
        p "For adult men and non-menstruating/post-menopausal women." 
        p "Don't take at the same time with medications, drugs, aspirin, Advil, Tylenol, Arimidex, etc."
        p "Don't take if you are anemia. Safety booklet comes inside each box. "
        p "For best results, take at a later time than Vitamin C."
        p {
          a("Longevinex.com", :href=>"http://www.longevinex.com/")
          span " - (866) – 405-4000 – $37 (1 box),  $120 (4 boxes) "
        }
      }
    }

    li {
      div.question "IP-6"
      div.answer {
        p "For full info. on this amazing supplement, buy the book above."
        p "As long as the cancer does not spread, don't worry over the tumor. "
        p "Shrink tumors by controlling your iron levels naturally with IP-6. "
        p "Take on an empty stomach with water only. No other vitamins/supplements at the same hour. "
        p "Don't take it if you have anemia.  Stop taking it when tumors are almost gone. "
        p "Bacteria, viruses, tumors all use excess iron in the body to grow. "
        p "IP-6 decreases iron levels, but must be used for a short time period (4 months or less)."
        p "Vitamin Shoppe. Buy the cheapest. They are all the same."
        p "Also available at: LuckyVitamin.com – 888-635-0474 - Source Naturals IP-6 - $10 – 90 tablets"
      }    
    }

  } # === ul
} # == div.content!



partial('__nav_bar')

