

show_if 'flash_msg?' do

  div.flash_msg! do
    show_if 'flash_success' do
      div.success do
        h4 'Success'
        div.msg '{{msg}}'
      end
    end

    show_if 'flash_errors' do
      div.errors do
        h4 '{{title}}'
        div.msg { 
          ul {
            loop 'errors' do 
              li '{{err}}'
            end
          }
        }
      end
    end
  end

end



