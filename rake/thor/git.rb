
require 'launchy'
require 'rest_client'

class Git < Thor

  include Thor::Sandbox::CoreFuncs

  desc :update, "Executes: git add . && git add -u && git status"
  def update
    invoke 'sass:compile'
    invoke 'python:sweep'
    say( output = capture_all('git add . && git add -u && git status'), :white )
    invoke 'sass:delete'
    output
  end

  desc :commit,  'Gathers comment and commits it. Example: git:commit message="My commit." '
  method_options :msg => :string
  def commit(msg = nil)

    output = invoke :update

    if commit_pending?(output)
      raw_comment = ( msg || options[:msg] || ask('===> Enter one line comment:', :white)  ).to_s.strip
      if raw_comment.empty?
        return shout('Comment must not be empty.')
      else
        say capture_all( 'git commit -m %s ', raw_comment)
        say "COMMITTED: #{raw_comment}", :white
      end
    else
      shout "NO GO: Nothing to commit."
    end

  end

  desc :dev_check, "Used to update and commit development checkpoint. Includes the commit comment for you."
  def dev_check
    invoke :commit, ['Development checkpoint.']
  end # === task

  desc :push, "Push code to Heroku. Options: migrate = false"
  method_options :migrate=>:boolean
  def push

    output = invoke(:update)

    if commit_pending?(output)
      say output
      say "NO GO: You *can't* push, unless you commit.", :red
      return output
    end

    # Check if specs all pass.
    #whisper capture_all('gem update')
    if invoke('bacon:all_pass?')
      say 'All specifications passed.', :white
    else
      invoke( 'bacon:all' )
      raise "Specs did not pass."
    end


    please_wait 'Please wait as code is being pushed to Heroku...'

    push_results = capture_all( 'git push heroku master')
    push_went_ok = push_results[ /deployed to Heroku/i ] && !push_results[ /(error|fail)/i ]
    if !push_went_ok
      shout push_results
      return false
    end
    
    whisper push_results
    
    if options[:migrate]
      shout 'Migrating on Heroku...'
      migrate_results = capture_all( "heroku rake production:migrate_up" )
      raise "Problem on executing migrate:up on Heroku." if migrate_results[/aborted/i]
      shout migrate_results

      #shout 'Restarting app servers.'
      #whisper capture_all('heroku restart')
    end


    app_name = File.basename(Pow().to_s)
    case app_name
      when 'miniuni'
        url = "http://#{app_name}.heroku.com/"
        check_this_url url, /mega/
      when 'megauni'
        url = "http://www.#{app_name}.com/"
        check_this_url url, /megauni/i
        check_this_url "http://www.busynoise.com/", /has moved/
        check_this_url "http://www.busynoise.com/egg/", /has moved/
        check_this_url "http://www.myeggtimer.com/", /new address/
        check_this_url "#{url}busy-noise/", /create_countdown/
        check_this_url "#{url}my-egg-timer/", /egg_template/
      else
        url = "http://www.#{app_name}.com/"
        check_this_url url, /#{app_name}/
    end

    Launchy.open( url )

    true

  end # === task

  desc :push_and_migrate_production, "Pushes code to Heroku. Migrates on the server side. Opens browser."
  def push_and_migrate_production
    invoke('git:push', [], :migrate=>true )
  end

  private # ===================================================

  def commit_pending?(raw_out)
    output = (raw_out || invoke(:update) )
    output['nothing to commit'] ?
      false :
      output
  end

  def check_this_url url, r_text
    begin
      results = RestClient.get( url )
      if results !~ r_text
        shout "Could not find #{r_text.inspect} @ #{url}"
      end
    rescue RestClient::ResourceNotFound, RestClient::RequestFailed, RestClient::RequestTimeout
      shout "Homepage problem: #{url} - #{$!.message}"
    end
  end
end # === Git

