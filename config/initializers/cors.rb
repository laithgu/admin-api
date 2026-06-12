# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Development: allow all origins
    # Production: change to specific domain, e.g. "https://your-frontend.com"
    origins "*"

    resource "*",
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             expose: ["Total-Count", "Current-Page"]
  end
end
