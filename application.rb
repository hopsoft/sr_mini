require "bundler/inline"

gemfile true do
  source "https://rubygems.org"
  gem "rails", "~> 6.1.3"
  gem "redis", "~> 4.2.5"
  gem "cable_ready", "~> 4.5.0"
  gem "stimulus_reflex", "~> 3.4.1"
  gem "puma", "~> 5.2.2"
  gem "pry"
end

require "rails/command"
require "rails/commands/server/server_command"
require "rails/all"

module ApplicationCable; end

class ApplicationCable::Connection < ActionCable::Connection::Base; end

class ApplicationCable::Channel < ActionCable::Channel::Base; end

class ApplicationController < ActionController::Base; end

class ApplicationReflex < StimulusReflex::Reflex; end

class CounterReflex < ApplicationReflex
  def increment
    @count = element.dataset.count.to_i + 1
  end
end

class DemosController < ApplicationController
  def show
    render inline: <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>StimulusReflex Mini Demo</title>
          <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet">
          <%= javascript_include_tag "/index.js", type: "module" %>
        </head>

        <body>
          <div class="container my-5">
            <h1>StimulusReflex <small class="text-muted fw-light">Mini Demo</small></h1>
            <button type="button" class="btn btn-primary" data-reflex="click->CounterReflex#increment" data-count="<%= @count.to_i %>">
              Increment <span class="badge rounded-pill bg-light text-primary ms-1"><%= @count.to_i %></span>
            </button>
          </div>
        </body>
      </html>
    HTML
  end
end

class MiniApp < Rails::Application
  require "stimulus_reflex/../../app/channels/stimulus_reflex/channel"

  config.action_controller.perform_caching = true
  config.consider_all_requests_local = true
  config.public_file_server.enabled = true
  config.secret_key_base = "36e8e087e279fe21b533b311c70beff7a1952c11bd121de9c9f86eca1aa3c08c7782344cbc7b2f1fc87ffea64515933fc52baeb29a86e2a1a42ed9578a0a047b"
  config.secret_token = "b5296f300ede8553606df0d656395bb760b04c31cdbb2df8cc5e8d6ffdcdba77f6c57ae54b51c7fd4874b6894f6290d5e41e172bcbfcd3554a1c45c161071d6c"
  config.session_store :cache_store

  Rails.cache = ActiveSupport::Cache::RedisCacheStore.new(url: "redis://localhost:6379/1")
  Rails.logger = ActionCable.server.config.logger = Logger.new($stdout)
  ActionCable.server.config.cable = {"adapter" => "redis", "url" => "redis://localhost:6379/1"}

  routes.draw do
    mount ActionCable.server => "/cable"
    resource :demo, only: :show
    root "demos#show"
  end
end

system("yarn && yarn build", exception: true)
Rails::Server.new(app: MiniApp, Host: "0.0.0.0", Port: 3000).start
