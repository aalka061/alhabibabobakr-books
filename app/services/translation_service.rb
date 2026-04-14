# ============================================================
# app/services/translation_service.rb
# ============================================================
require "net/http"
require "uri"
require "json"

class TranslationService
  ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages"
  MODEL             = "claude-sonnet-4-20250514"
  CHUNK_SIZE        = 20

  def self.translate(lines, prompt: nil)
    new(prompt: prompt).translate(lines)
  end

  def initialize(prompt: nil)
    @prompt = prompt || TranslationPrompt::DEFAULT
  end

  def translate(lines)
    lines.each_slice(CHUNK_SIZE).flat_map.with_index do |chunk, chunk_idx|
      offset = chunk_idx * CHUNK_SIZE
      Rails.logger.info "[Translator] Translating lines #{offset + 1}–#{offset + chunk.size} / #{lines.size}"
      translate_chunk(chunk)
    end
  end

  private

  def translate_chunk(chunk)
    numbered = chunk.each_with_index.map { |line, i| "#{i + 1}. #{line}" }.join("\n")

    # Combines your chosen prompt with the numbered lines to translate
    full_prompt = "#{@prompt.strip}\n\n#{numbered}"

    response_text = call_anthropic(full_prompt)
    translations  = parse_numbered_list(response_text)

    chunk.each_with_index.map do |arabic, i|
      { arabic: arabic, english: translations[i + 1] || "[Translation unavailable]" }
    end
  end

  def call_anthropic(prompt)
    uri  = URI(ANTHROPIC_API_URL)
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

    raise "Anthropic API error: #{body.dig("error", "message") || response.body}" unless response.is_a?(Net::HTTPSuccess)

    body.dig("content", 0, "text").to_s.strip
  end

  def parse_numbered_list(text)
    translations = {}
    text.each_line do |line|
      if (m = line.strip.match(/^(\d+)\.\s*(.+)/))
        translations[m[1].to_i] = m[2].strip
      end
    end
    translations
  end
end
