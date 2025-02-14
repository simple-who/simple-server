Rails.application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Attempt to read encrypted secrets from `config/secrets.yml.enc`.
  # Requires an encryption key in `ENV["RAILS_MASTER_KEY"]` or
  # `config/secrets.yml.key`.
  config.read_encrypted_secrets = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)

  # Do fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Use a different cache store in production.
  config.cache_store = if ENV["RAILS_CACHE_REDIS_URL"].present?
    [:redis_cache_store, {url: ENV["RAILS_CACHE_REDIS_URL"]}]
  else
    [:redis_cache_store, {url: ENV["REDIS_URL"]}]
  end

  # Use a real queuing backend for Active Job (and separate queues per environment)
  config.active_job.queue_adapter = :sidekiq
  # config.active_job.queue_name_prefix = "simple-server_#{Rails.env}"
  config.action_mailer.deliver_later_queue_name = "default"

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = {host: "localhost", port: 3000}
  config.action_mailer.asset_host = "http://localhost:3000"

  # Use Mailcatcher to test mail in development
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {address: "localhost", port: 1025}

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = JsonLogger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
