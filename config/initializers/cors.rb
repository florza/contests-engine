# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins /https?:\/\/contest.*\.herokuapp.com(:\d+)?\/?/,  # Heroku
            'http://localhost:5000', 'http://0.0.0.0:5000',   # dev localhost
            /http:\/\/192\.168\.\d{1,3}\.\d{1,3}(:\d+)?\/?/   # dev LAN

    resource '*',
      headers: :any,
      credentials: true,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
