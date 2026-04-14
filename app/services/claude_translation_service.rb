# ============================================================
# app/services/claude_translation_service.rb
# ============================================================
require "net/http"
require "uri"
require "json"

class ClaudeTranslationService < BaseTranslationService
  API_URL = "https://api.anthropic.com/v1/messages"
  MODEL   = "claude-sonnet-4-20250514"

  private

  def call_api(prompt)
    uri  = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"]      = "application/json"
    request["x-api-key"]         = ENV.fetch("ANTHROPIC_API_KEY")
    request["anthropic-version"] = "2023-06-01"
    request.body = {
      model:      MODEL,
      max_tokens: 2000,
      messages:   [ { role: "user", content: prompt } ]
    }.to_json

    response = http.request(request)
    body     = JSON.parse(response.body)

    raise "Claude API error: #{body.dig("error", "message") || response.body}" unless response.is_a?(Net::HTTPSuccess)

    body.dig("content", 0, "text").to_s.strip
  end
end
