save_to('title') {
  'Egg Timer'
}


save_to('keywords') {
  'online web timer'
} 

save_to('description') {
  'An online web timer. Test only on Firefox/Ubuntu.'
}


save_to('javascripts') {

  text the_app.script_tag('/js/vendor/soundmanager2/script/soundmanager2.js')
  text the_app.script_tag('/js/vendor/jquery.1.3.2.min.js')
  text the_app.script_tag('/js/vendor/jquery.cookie.js')
  text the_app.script_tag('/js/swiss.js')
  text the_app.script_tag('/js/pages/timer_show.js')
  
}


save_to('opening_msg') {
    div( :id=>'big_clock' ) { 
      p.day "---"
      p.date "----"
      p.time  "---" 
      p.seconds "----"
    }
} # === save_to

partial('__nav_bar')


div.content! { 
  

  div.work! {
div.countdown.job { 
  div.undo(:style=>'display: none') { 
    div { 
      span  "You have deleted egg timer: " 
      span.short_headline  "---" 
    }
    div { 
      a.undo( "Undo deletion.", :href=>'#egg_undelete'  ) 
    }
  }

  div.status { 
    a.play 'Play', :href=>'#play', :onclick=>'javascript:EggClock.play(this)'
    div.time_status { 
      
      span.number '9'
      span.unit 'm'
      span.number '19'
      span.unit 's'
    }
    a.pause 'Pause', :href=>'#play', :onclick=>'javascript:EggClock.play(this)'
    div.buzzer_option.selected_buzzer { 
      input( :checked=>'checked', :name=>'sound_alarm', :type=>'checkbox' , :value=>'true'   )  
      span { "Ring when done." }
    }
    
  }
  div.summary { 
    h4 { "Dinner's ready" }
    div.setting { "9 min countdown" }
    ul.control_panel { 
      li {
        a.check_mark( "Check Mark", :href=>'#egg_check_marked'  ) 
      }
      li {
        a.x_mark( "X Mark" , :href=>'#egg_x_marked'  ) 
      }

      li {
        a.edit( "Edit / Delete" , :href=>'#egg_edit'  ) 
      }
    }
    div.details_control_panel { 
      a.show(  :href=>'#egg_show_details'  ) { "View Details" }
      a.hide(  :href=>'#egg_hide_details'  ) { "Hide Details" }
    }
    div.details { "Travel to Europe." }
  }
} # === div.countdown


div.countdown.job.running { 
  div.undo(:style=>'display: none') { 
    div { 
      span  "You have deleted egg timer: " 
      span.short_headline  "---" 
    }
    div { 
      a.undo( "Undo deletion.", :href=>'#egg_undelete'  ) 
    }
  }

  div.status { 
    a.play 'Play', :href=>'#play', :onclick=>'javascript:EggClock.play(this)'
    div.time_status { 
      span.unit '-'
      span.number '8'
      span.unit 'm'
      span.number '12'
      span.unit 's'
    }
    a.pause 'Pause', :href=>'#play', :onclick=>'javascript:EggClock.play(this)'
    div.buzzer_option.selected_buzzer { 
      input( :checked=>'checked', :name=>'sound_alarm', :type=>'checkbox' , :value=>'true'   )  
      span { "Ring when done." }
    }
    
  }
  div.summary { 
    h4 { "Dinner's ready" }
    div.setting { "9 min countdown" }
    ul.control_panel { 
      li {
        a.check_mark( "Check Mark", :href=>'#egg_check_marked'  ) 
      }
      li {
        a.x_mark( "X Mark" , :href=>'#egg_x_marked'  ) 
      }

      li {
        a.edit( "Edit / Delete" , :href=>'#egg_edit'  ) 
      }
    }
    div.details_control_panel { 
      a.show(  :href=>'#egg_show_details'  ) { "View Details" }
      a.hide(  :href=>'#egg_hide_details'  ) { "Hide Details" }
    }
    div.details { "Travel to Europe." }
  }
} # === div.countdown


div.countdown.job.paused { 
  div.undo(:style=>'display: none') { 
    div { 
      span  "You have deleted egg timer: " 
      span.short_headline  "---" 
    }
    div { 
      a.undo( "Undo deletion.", :href=>'#egg_undelete'  ) 
    }
  }

  div.status { 
    a.play 'Play', :href=>'#play', :onclick=>'javascript:EggClock.play(this)'
    a.continue 'Continue', :href=>'#continue', :onclick=>'javascript:EggClock.play(this)'
    a.start_over 'Start Over', :href=>'#start_over', :onclick=>'javascript:EggClock.play(this)'
    a.pause 'Pause', :href=>'#play', :onclick=>'javascript:EggClock.play(this)'
    div.time_status { 
      span.unit '-'
      span.number '4'
      span.unit 'm'
      span.number '8'
      span.unit 's'
    }
    
    div.buzzer_option.selected_buzzer { 
      input( :checked=>'checked', :name=>'sound_alarm', :type=>'checkbox' , :value=>'true'   )  
      span { "Ring when done." }
    }
    
  }
  div.summary { 
    h4 { "Dinner's ready" }
    div.setting { "9 min countdown" }
    ul.control_panel { 
      li {
        a.check_mark( "Check Mark", :href=>'#egg_check_marked'  ) 
      }
      li {
        a.x_mark( "X Mark" , :href=>'#egg_x_marked'  ) 
      }

      li {
        a.edit( "Edit / Delete" , :href=>'#egg_edit'  ) 
      }
    }
    div.details_control_panel { 
      a.show(  :href=>'#egg_show_details'  ) { "View Details" }
      a.hide(  :href=>'#egg_hide_details'  ) { "Hide Details" }
    }
    div.details { "Travel to Europe." }
  }
} # === div.countdown


div.job.alarm { 
  div.undo { 
    div { 
      span { "You have deleted alarm:&nbsp;" }
      span.short_headline { "--" }
    }
    div { 
      a.undo(  :href=>'#egg_undelete'  ) { "Undo deletion." }
    }
  }

  div.status { 
    div.time_status { 
      span.number { "* * * *" }
    }     
  }
  div.summary { 
    h4 "[title]"
    div.setting  "[x mins]" 
    ul.control_panel { 
      li {
        a.play(  :href=>'#egg_at_play'  ) { "Play" }
      }
      li {
        a.check_mark(  :href=>'#egg_check_marked'  ) { "Check Mark This" }
      }
      li {
        a.x_mark(  :href=>'#egg_x_marked'  ) { "X Mark This" }
      }
      li {
        a.ready_to_start(  :href=>'#egg_ready_to_start'  ) { "Start All Over" }
      }
      li {
        a.edit(  :href=>'#egg_edit'  ) { "Edit / Delete" }
      }
    }
    div.details_control_panel { 
      a.show(  :href=>'#egg_show_details'  ) { "View Details" }
      a.hide(  :href=>'#egg_hide_details'  ) { "Hide Details" }
    }
    div.details { "[details]" }
  }
} # === div.template.alarm

  } # === div.work!
  
  ul { 
  
    li.selected { 
      a( 'Instructions:', :href=>'#instructions', :onclick=>"Swiss.tab.select( this ); return false;" )         
    }
    
    li  { 
      a( 'Egg Timer:', :href=>'#create_countdown', :onclick=>"Swiss.tab.select( this ); return false;" )   
    }
    
    li  { 
      a( 'Time Alarm:',  :href=>'#create_alarm', :onclick=>"Swiss.tab.select( this ); return false;" ) 
    }
       
    li  { 
      a( 'Notes:',  :href=>'#create_note', :onclick=>"Swiss.tab.select( this ); return false;" ) 
    }
  } # === ul.binder  
  

  div.form.tab_selected.instructions!  { 
  
    ol { 
      
      li.one  { 
        div.title "Create a new alarm, note or egg timer."
      }
      
      li.two  { 
        div.title "Turn up speaker volumn." 
        div.body { 
          a.start_test!( :href=>'#start', :onclick=>"return Instruct.start_test();" ) { 
            "Click here to test your speakers."
          }
          a.stop_test!(  :href=>'#stop', :onclick=>"return Instruct.stop_test();" ) { 
            "Stop test." 
          }
        }
      }
      
      li.three  { 
        div.title  "Repeat step 1." 
        div.body { 
          span "You can add multiple countdowns/alarms/notes."
        }
      }
      
    } # === ol
    
  } # === div.instructions!
  
  div.form.tab_unselected.create_note!  { 

    form( :action=>'/', :class=>'create_egg', :id=>'form_note' , :method=>'post'  ) { 

      fieldset { 
        label { "Title:" }
        input.text(  :maxlength=>'200', :name=>'headline' , :type=>'text',  :value=>'' ) 
      }

      fieldset.textarea { 
        label { "Details:" }
        textarea(  '', :cols=>'10', :name=>'details' , :rows=>'5'  )  
      }

      div.buttons { 
        button.save( "Save & Post" , :onclick=>"return Post.note();") 
      }
      
    } # === div.form

  } # === div.create_note!          
  
  div.form.tab_unselected.create_countdown!  { 

      form( :action=>'/', :class=>'create_egg', :id=>'form_countdown' , :method=>'post'  ) { 

        div.time_units_block.group { 
          
          div.title { "Type in units:" }
          
          fieldset.input_text.days { 
            input.text( :maxlength=>'3', :name=>'days', :type=>'text' , :value=>'0'   ) 
            label  "Days" 
          }
          
          fieldset.input_text { 
            input.text( :maxlength=>'3', :name=>'hours', :type=>'text' , :value=>'0'   ) 
            label  "Hrs." 
          }
          
          fieldset.input_text { 
            input.text( :maxlength=>'3', :name=>'minutes', :type=>'text' , :value=>'15'   )  
            label  "Mins." 
          }
          
          fieldset.input_text { 
            input.text( :maxlength=>'3', :name=>'seconds', :type=>'text' , :value=>'0'   )  
            label  "Secs." 
          }
          
        } # === div.time_units_block
        

        fieldset { 
          label  "Title:" 
          input.text(  :maxlength=>'200', :name=>'headline' , :type=>'text',  :value=>''   )  
        }
        

        fieldset { 
          label { "Details:" }
          textarea.text.name( '', :cols=>'10', :name=>'details' , :rows=>'5'  ) 
        }

        div.buttons { 
          button.save( "Save & Run", :onclick=>'return Post.countdown();' )
        }
        
      } # === form

  } # === div.create_countdown!          


  div.form.tab_unselected.create_alarm!  { 

      form( :action=>'/', :class=>'create_egg', :id=>'form_alarm' , :method=>'post'  ) { 

        div.title  "Select Time:" 
        
        div.group {
          fieldset { 
            select.hours(  :name=>'hours'  ) { 
              option( :selected=>'selected', :value=>'1'  ) { "1" }
              (2..11).to_a.each { |i|
                option( :value=>i ) { i.to_s }
              }
              option( :value=>'0' ) { "12" }
            }
          }
          
          fieldset { 
            select.minutes(  :name=>'minutes'  ) { 
              option( :selected=>'selected', :value=>'0'  ) { "00" }
              option( :value=>'15' ) { "15" }
              option( :value=>'30' ) { "30" }
              option( :value=>'45' ) { "45" }
            }
          }
          
          fieldset { 
            select.am_pm(  :name=>'am_pm'  ) { 
              option( :selected=>'selected', :value=>'am'  ) { "AM" }
              option( :value=>'pm' ) { "PM" }
            }
          }
        
        } # === div.group
        
        fieldset { 
          label { "Title:" }
          input.text(  :maxlength=>'200', :name=>'headline' , :type=>'text', :value=>''   )  
        }

        

        fieldset { 
          label { "Details:" }
          textarea.text.name( '', :cols=>'10', :name=>'details' , :rows=>'5'  ) 
        }

        
        div.buttons { 
          button.save( "Save & Run", :onclick=>'return Post.alarm();' )
        }
        
      } # === form 

  } # === div.create_alarm!          
        
  
} # === div.content!









div.template.note { 
  div.undo { 
    div { 
      span { "You have deleted note:&nbsp;" }
      span.short_headline { "---" }
    }
    div { 
      a.undo(  :href=>'#egg_undelete'  ) { "Undo deletion." }
    }
  }
  div.control_panel { 
    div.buttons { 
      a.ready_to_start(  :href=>'#egg_ready_to_start'  ) { "Start All Over" }
      a.check_mark(  :href=>'#egg_check_marked'  ) { "Check Mark This" }
      a.x_mark(  :href=>'#egg_x_marked'  ) { "X Mark This" }
      a.edit(  :href=>'#egg_edit'  ) { "Edit / Delete" }
    }
  }
  div.status { }
  div.summary { 
    h4 { "[title]" }
    div.setting { "Note" }
    div.details_control_panel { 
      a.show(  :href=>'#egg_show_details'  ) { "View Details" }
      a.hide(  :href=>'#egg_hide_details'  ) { "Hide Details" }
    }
    div.details { "[details]" }
  }
} # === div.template.note


div.form.template.note_editor! { 
  div.short_headline { 
    span { "Editing:&nbsp;" }
    span.short_headline { }
  }
  div.land { 
    form( :action=>'/', :class=>'create_egg', :method=>'post'  ) { 
      div.fieldset_block.headline { 
        fieldset { 
          label { "Headline:" }
          input.text.name(  :maxlength=>'200', :name=>'headline' , :type=>'text',  :value=>''  )  
        }
      }
      div.fieldset_block.details { 
        fieldset { 
          label { "Details:" }
          textarea.text.name( '', :cols=>'10', :name=>'details' , :rows=>'5'  )
        }
      }
      div.buttons { 
        button.save  "Save" 
        button.cancel  "Cancel" 
        button.delete   "Delete Note" 
      }
    }
  }
}


div.form.editor.countdown_editor! { 
  div.short_headline { 
    span { "Editing:&nbsp;" }
    span.short_headline { }
  }
  div.land { 
    form( :action=>'/', :class=>'create_egg', :method=>'post'  ) { 
      div.fieldset_block.time_units_block { 
        div.title { "Type in units:" }
        fieldset { 
          input( :maxlength=>'3', :name=>'days', :type=>'text' , :value=>'0'   ) 
          label { "Days" }
        }
        fieldset { 
          input( :maxlength=>'3', :name=>'hours', :type=>'text' , :value=>'0'   ) 
          label { "Hrs." }
        }
        fieldset { 
          input( :maxlength=>'3', :name=>'minutes', :type=>'text' , :value=>'15'   ) 
          label { "Mins." }
        }
        fieldset { 
          input( :maxlength=>'3', :name=>'seconds', :type=>'text' , :value=>'0'   )  
          label { "Secs." }
        }
      }
      div.fieldset_block.headline { 
        fieldset { 
          label { "Title:" }
          input.text.name(  :maxlength=>'200', :name=>'headline' , :type=>'text', :value=>''   )  
        }
      }
      div.fieldset_block.details { 
        fieldset { 
          label { "Details:" }
          textarea.text.name(  '', :cols=>'10', :name=>'details' , :rows=>'5'  )  
        }
      }
      div.buttons { 
        button.save  "Save" 
        button.cancel  "Cancel" 
        button.delete  "Delete EggTimer" 
      }
    }
  }
}


div.form.editor.alarm_editor!  { 
  div.short_headline { 
    span  "Editing: &" 
    span.short_headline { }
  }
  div.land { 
    form( :action=>'/', :class=>'create_egg', :method=>'post'  ) { 
      div.fieldset_block.time_units_block { 
        div.title  "Select Time:" 
        fieldset { 
          select.hours(  :name=>'hours'  ) { 
            (1..11).to_a.each { |i|
              option( :value=>i ) { i.to_s }
            }
            option( :value=>'0' ) { "12" }
          }
        }
        fieldset { 
          select.minutes(  :name=>'minutes'  ) { 
            option( :value=>'0' ) { "00" }
            option( :value=>'15' ) { "15" }
            option( :value=>'30' ) { "30" }
            option( :value=>'45' ) { "45" }
          }
        }
        fieldset { 
          select.am_pm(  :name=>'am_pm'  ) { 
            option( :value=>'am' ) { "AM" }
            option( :value=>'pm' ) { "PM" }
          }
        }
      }
      div.fieldset_block.headline { 
        fieldset { 
          label  "Title:" 
          input.text.name(  :maxlength=>'200', :name=>'headline' , :type=>'text', :value=>''   )  
        }
      }
      div.fieldset_block.details { 
        fieldset { 
          label  "Details:" 
          textarea.text.name(  '', :cols=>'10', :name=>'details' , :rows=>'5'  ) 
        }
      }
      div.buttons { 
        button.save  "Save" 
        button.cancel  "Cancel" 
        button.delete  "Delete Alarm" 
      }
    }
  }
} # === div.edit_alarm

  
  
