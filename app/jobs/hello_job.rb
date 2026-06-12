class HelloJob < ApplicationJob
  queue_as :default

  def perform(name)
    Rails.logger.info "👋 Hello, #{name}! Job executed at #{Time.current}"
    puts "👋 Hello, #{name}! Job executed at #{Time.current}"
  end

end
