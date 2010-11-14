require 'models/Private_Mab'
require 'models/Concise_Attrs'

module Ruby_To_Html::Base_Forms

  extend Concise_Attrs
  attr_reader :as_type, :config_scope
  attr_concise :action, :show_target, :show

  %w{ radios check_boxes menu }.each { |type|
    eval %~
      def as_#{type} 
        @as_type = :#{type}
      end

      def as_#{type}?
        @as_type == :#{type}
      end
    ~

  }

  def form_config
    Config_Switches.new {
      strings :id, :action, :method, :field, :collection
      array :class
      string_or_block :show, :button_create, :submit
      switch :as_radios, off
      switch :as_menu, off
      switch :as_check_boxes, off
    } 
  end

  def a_click txt
    a_show txt
  end
  
  def a_show txt
    raise "Block not yet used" if block_given?
    target = config_scope ? config_scope.get.id.first : 'UNKNOWN'
    a(
      txt, 
      :href => "#show-#{target}",
      :onclick => js {
        id(target).remove_class('hidden')
        this.parent('div').remove
        return_false
      } 
    )
  end

  def _method_delete
    text(capture { 
      input :type=>'hidden', :name=>'_method', :value=>'delete' 
    })
  end
  
  def _method_put
    text(capture { 
      input :type=>'hidden', :name=>'_method', :value=>'put' 
    })
  end

  def fieldset_hidden &blok
    text(capture {
      fieldset.hidden {
        instance_eval( &blok )
      }
    })
  end

  def input_hidden name, value = ''
    input :type=>'hidden', :name=>name, :value=>value
  end

  def input_text name, val= ''
    text(capture {
      input.text :type=>'text', :name=>name, :value=>val
    })
  end

  def label_to_name slabel
    slabel.downcase.gsub(/[^a-z0-9\_\-]/i, '')
  end

  def button_create txt = 'Save'
    div.buttons {
      button.create txt #, :onclick => js! { parent_form.submit }
    }
  end

  def button_submit txt = 'Save'
    div.buttons {
      button.submit txt #, :onclick => js! { parent_form.submit }
    }
  end

  def button_update txt = 'Update'
    div.buttons {
      button.update txt #, :onclick => js! { parent_form.submit }
    }
  end
  
  def a_submit txt, href = nil
    context = self
    a( 
      txt, 
      :href    => "#save", 
      :onclick => js {
        element(context.show_target) {
          parents('div').add_class('loading')
          attr('action', context.action )
          submit();
        }
        return_false
       }
    )
  end

  def fieldset *args, &blok
    case args.size
    when 0
      return super(*args, &blok)
    when 2
      label_txt = args.first
      name      = label_to_name(args.first)
      val       = args.last
    when 3
      label_txt, name, val = args
    else
      raise ArgumentError, "Argument size can only be 0, 2, or 3: #{args.inspect}"
    end
    
    fieldset.text {
      label label_txt
      input_text name, val
    }
  end

  # Uses a TEXTAREA instead of an INPUT[type=text].
  def fieldset! *args
    case args.size
    when 2
      label_txt = args.first
      name      = label_to_name(args.first)
      val       = args.last
    when 3
      label_txt, name, val = args
    else
      raise ArgumentError, "Argument size can only be 0, 2, or 3: #{args.inspect}"
    end
    
    fieldset.textarea {
      label label_txt
      textarea( val || '', :name=>name )
    }
  end

  # Example:
  #   checkboxes_for 'news_tags', :name=>'tags[]'
  #
  # Parameters:
  #   coll - String. Name of Array to be used in 
  #          Mustache template.
  #          Each item must be a Hash in the form of:
  #           :selected?
  #           :not_selected?
  #           :value - Optional.
  #   
  def checkboxes_for coll, &blok
    
    @checkbox ||= Class.new do 
      
      def initialize &blok
        instance_eval(&blok)
      end
      
      def text txt
        @text = txt
      end
      
      def value txt
        @value = txt
      end
      
      def name txt
        @name = txt
      end
      
      def props
        [   
          @text, 
          { :name => @name, 
            :type => 'checkbox', 
            :value => @value 
          } 
        ]
      end
      
    end
    
    span_txt, attrs = @checkbox.new(&blok).props
    ele_id = "checkbox_#{rand(1000)}_#{attrs[:value]}"
    s_ele_id = "selected_checkbox_#{rand(1000)}_#{attrs[:value]}"
    
    text(capture {
      loop coll do
      
        show_if 'selected?' do
          div.box.selected {
            input( {:checked=>'checked', :id=>s_ele_id}.update attrs )
            label span_txt, :for=>s_ele_id
          }
        end
        
        if_not 'selected?' do
          div.box {
            input( {:id=>ele_id}.update attrs )
            label span_txt, :for=>ele_id
          }
        end
        
      end # === loop
    })

  end # === checkboxes_for

  def menu_for coll, select_attrs={}, &blok
    @option_class = Class.new do
      attr_reader :results
      def initialize &blok
        instance_eval(&blok)
      end
      def option *args
        @results = args
      end
    end
    
    opt_txt, attrs = @option_class.new(&blok).results
    attrs[:value] = "{{#{attrs[:value]}}}"
    
    txt = (capture { 
      select(select_attrs) {
        loop coll do
          show_if 'selected?' do
            option "{{#{opt_txt}}}", {:selected=>'selected'}.update(attrs)
          end 
          if_not 'selected?' do
            option "{{#{opt_txt}}}"
          end
        end
      }
    })
    text txt
  end

  def radios_for mus
    yield
    ele_id = "radio_#{rand(1000)}_#{radio_value}"
    loop mus do
      div.radio {
        input :type => 'radio', :name => ele_id, :id => ele_id, :value => radio_value
        label radio_txt,  :for=>ele_id
      }
    end
  end

  def radio name, value, txt
    @radio_name = name
    @radio_value = value
    @radio_txt = txt
  end

  def toggle_forms
    @toggle_forms ||= []
  end

  def toggle_forms_include?(config)
    toggle_forms.detect { |form| form.get.id === config.get.id }
  end

  def toggle txt, value
    get = config_scope.get
    ask = config_scope.ask
      a( 
        txt, 
        :href => "##{get.id}",
        :onclick => %~
          $(this).parent('div').addClass('loading');
          $('##{get.id} input[name=#{get.field}]').val(#{value.inspect});
          $('##{get.id}').submit();
          return false;
        ~
      )
  end

  def render_toggle_forms
    return if toggle_forms.empty?
    toggle_forms.each { | config |
      config.put.method 'post'
      field_name = config.get.field
      text(capture {
        form(config.as_hash(:id, :action, :method, :class)) {
          fieldset_hidden {
            _method_put    
            input_hidden field_name, '0'
            input_hidden 'editor_id', '{{editor_id}}'
          }
        }
      })
    }
  end
  
  def toggle_form sId, sAction, sField, &blok
    config = form_config
    config.put {
      action sAction
      id     "toggle_form_#{sId}"
      field  sField
    }
    ask = config.ask
    get = config.get
    put = config.put
    @config_scope = config
    
    (toggle_forms << config) unless toggle_forms_include?(config)
    yield
    @config_scope = nil
  end

  def put_form config, &blok
    form_post(config) {
      yield
    }
  end

  def form_post *args
    @config_scope = config = if args.first.is_a?(Config_Switches)
                               args.first
                             else
                               config = form_config
                               config.put {
                                 id      args[0]
                                 action  args[1]
                                 show    config.get.id
                               }
                               config
                             end
    
    config.put.method 'post'
    ask = config.ask
    get = config.get
    
    if ask.show?
      get.class << 'hidden'
    end
    
    form( config.as_hash(:id, :action, :class, :method) ) {
      yield
      if ask.button_create?
        div.buttons {
          button_create get.button_create
        }
      end
      if ask.submit?
        if get.submit.first
          a_submit(get.submit.first)
        end
        if get.submit.last
          instance_eval(&get.submit.last)
        end
      end
    }
    
    if ask.show?
      div {
        if get.show.last.is_a?(Proc)
          text capture(&get.show.last)
        elsif get.show.first.is_a?(String)
            text( capture { 
              a_show get.show.first 
            })
        end
      }
    end
    @config_scope = nil
  end

  def show &blok
    return @show if not block_given?
    @show = capture { 
      div { yield }
    }
  end
  
  def post_to_universes raw_id, &configuration
    config  = form_config
    
    config.put {
      id         "post_to_universes_#{raw_id}"
      collection "#{raw_id}_menu"
      instance_eval( &configuration )
    }
    
    get = config.get
    
    form_post(config) {
      loop(get.collection) do
        h4 '{{username}}'
        checkboxes_for('clubs') {
          text  '{{title}}'
          value '{{_id}}'
          name  'clubs[]'
        }
      end
    }
  end

  # Uses a View collection name composed of:
  #   #{raw_form_id}_menu
  def post_to_username raw_form_id, &blok
    config = form_config
    ask = config.ask
    get = config.get
    
    config.string :collection_name
    has_field = ask.field?
    
    config.put {
      id              "post_to_username_#{raw_form_id}"
      collection_name "#{raw_form_id}_menu"
      field( 'owner_id' ) unless has_field
      instance_eval( &blok )
    }

    form_post(config) {
      if ask.as_radios?
        radios_for( get.collection_name ) {
          radio get.field, '{{username_id}}', '{{username}}'
        }
      end
    }
  end

  def delete_form raw_form_id, &blok
    config = form_config
    config.put.id "delete_form_#{raw_form_id}"
    config.put &blok
    
    form_post config do
      fieldset_hidden {
        _method_delete
      }
    end
  end
  
end # === module Base_Forms
