# VIEW ~/megauni/views/Hellos_help.rb
# SASS ~/megauni/templates/en-us/css/Hellos_help.sass
# NAME Hello_help

div.content! { 
  
  ul.faq {
  
    # li {
    #   div.question "How much does MegaUni.com cost?"
    #   div.answer {
    #     ul {
    #       li "$0   - Young & Poor: friends, family features"
    #       li "$36  - Single & Working: friends, family, work, romance features."
    #       li "$48  - Circle of Friends: All features + 4 accounts for your family/friends."
    #       li "$120 - Small Business: All features + 24 accounts for your hard working co-workers."
    #     }
    #   }
    # }

    li {
      div.question "What is MegaUNi.com?"
      div.answer {
        span "A personal list of all my favorite products."
      }
    }

    li {
      div.question "I want to contact you personally... and threaten legal action."
      div.answer {
        span "Until I can get the comments section working, contact this email:"
        br
        span "help [at] megauni [dot] com"
      }
    }

    li {
      div.question "I can't view this website properly on my phone."
      div.answer {
        span "It's going to be like that for a while. I'm still working on the 
        regular HTML version, so a proper mobile version is at least a year away."
      }
    }

  } # === ul
  
} # === div.content!

partial('__nav_bar')

