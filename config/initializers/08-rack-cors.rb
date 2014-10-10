if (GlobalSetting.enable_cors && GlobalSetting.cors_origin.present?) || GlobalSetting.enable_multisite_cors
  class Discourse::Cors
    def initialize(app, options = nil)
      @app = app
      if GlobalSetting.enable_cors
        @global_origins = GlobalSetting.cors_origin.split(',').map(&:strip)
      end
    end

    def call(env)
      status, headers, body = @app.call(env)
      origin = nil

      if @global_origins
        if origin = env['HTTP_ORIGIN']
          origin = nil unless @global_origins.include? origin
        end

        headers['Access-Control-Allow-Origin'] = origin || @global_origins[0]
        headers['Access-Control-Allow-Credentials'] = "true"
      else
        # multisite CORS
        config = ActiveRecord::Base.connection_pool.spec.config
        site_origins = (config && config[:cors_origin]) ? config[:cors_origin].split(',') : nil

        if site_origins
          if origin = env['HTTP_ORIGIN']
            origin = nil unless site_origins.include?(origin)
          end

          headers['Access-Control-Allow-Origin'] = origin || site_origins.try(:first)
          headers['Access-Control-Allow-Credentials'] = "true"
        end
      end

      [status,headers,body]
    end
  end

  Rails.configuration.middleware.insert 0, Discourse::Cors
end
