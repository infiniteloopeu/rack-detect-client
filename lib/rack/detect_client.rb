require 'set'

module Rack
  class DetectClient

    def initialize(app, opts = {})
      @app = app

      @subdomain = {}
      @subdomain[:iphone] = opts[:iphone_subdomain] || 'i'
      @subdomain[:mobile] = opts[:mobile_subdomain] || 'm'
      @subdomain[:global] = opts[:global_subdomain] || 'g'
      @subdomain[:default] = opts[:default_subdomain] || @subdomain[:global]

      @force_client_subdomain = opts[:force_client_subdomain] || false

      @never_redirect = opts[:never_redirect] || false
    end

    CLIENT_TYPE_ENVIRONMENT_KEY = 'x-rack.client-type'.freeze

    def call_debug(env)
      [200, {}, env.map{|k,v| "#{k} = #{v}"}.join("<BR>")]
    end

    def call(env)
      sub = first_subdomain(env['HTTP_HOST'])
      client_type = detect_client_capabilities(env)
      client_type = 'm'
      env[CLIENT_TYPE_ENVIRONMENT_KEY] = client_type

      if @never_redirect || 
         (@subdomain.values.include?(sub) && !@force_client_subdomain) ||
         client_type == @subdomain[:global] || 
         client_type == sub
        @app.call(env)
      else
        new_host = "http://%s.%s%s" % [client_type, remove_first_subdomain(env['HTTP_HOST']), env['REQUEST_PATH']]
        [301, {'Location' => URI.parse(new_host).to_s}, "You are being redirected..."]
      end
    end
    
    private

    def remove_first_subdomain(hostname)
      r = Regexp.new("^(www|#{@subdomain.values.join("|")})\\.")
      if hostname =~ r 
        hostname.split('.')[1..-1].join('.')
      else
        hostname
      end
    end

    def first_subdomain(hostname)
      parts = hostname.split(".")
      parts[0]
    end


    MobiUserAgentRegexp = /(up.browser|up.link|mmp|symbian|smartphone|midp|wap|phone)/i
    MobileAcceptString = 'application/vnd.wap.xhtml+xml'
    MobileUserAgentsSet = ['w3c ','acs-','alav','alca','amoi','audi','avan','benq','bird','blac',
      'blaz','brew','cell','cldc','cmd-','dang','doco','eric','hipt','inno',
      'ipaq','java','jigs','kddi','keji','leno','lg-c','lg-d','lg-g','lge-',
      'maui','maxo','midp','mits','mmef','mobi','mot-','moto','mwbp','nec-',
      'newt','noki','oper','palm','pana','pant','phil','play','port','prox',
      'qwap','sage','sams','sany','sch-','sec-','send','seri','sgh-','shar',
      'sie-','siem','smal','smar','sony','sph-','symb','t-mo','teli','tim-',
      'tosh','tsm-','upg1','upsi','vk-v','voda','wap-','wapa','wapi','wapp',
      'wapr','webc','winw','winw','xda','xda-'].to_set
    PleevoAgentUserType = 'pl-a'

    def detect_client_capabilities(env)
      user_agent = env["HTTP_USER_AGENT"]
      # Check if user has iphone [or another rich mobile browser]
      if (user_agent && user_agent[/(Mobile\/?.+Safari)/]) ||
         (user_agent && user_agent[/(Linux.+Android.+Safari)/])
        return @subdomain[:iphone]
        # Check if user has poor mobile browser
      elsif (user_agent[MobiUserAgentRegexp] || # returns true if iphone!
          env['HTTP_ACCEPT'].include?(MobileAcceptString) ||
            env['HTTP_X_WAP_PROFILE'] ||
            env['HTTP_PROFILE'] ||
            MobileUserAgentsSet.include?(user_agent[0..3]) ||
            env['ALL_HTTP'] && env['ALL_HTTP'][/OperaMini/]) &&
          ! user_agent[/windows/i]
        return @subdomain[:mobile]
        # User has desktop browser
      else
        return @subdomain[:global]
      end
    rescue
      @subdomain[:global]
    end
  end
end
