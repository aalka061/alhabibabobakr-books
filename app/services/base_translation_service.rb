# ============================================================
# app/services/base_translation_service.rb
# ============================================================
# Shared logic for all translation providers.
# Subclasses only need to implement `call_api(prompt)`.
class BaseTranslationService
  CHUNK_SIZE = 20

  def self.translate(lines, prompt: nil)
    new(prompt: prompt).translate(lines)
  end

  def initialize(prompt: nil)
    @prompt = prompt || TranslationPrompt::DEFAULT
  end

  def translate(lines)
    lines.each_slice(CHUNK_SIZE).flat_map.with_index do |chunk, chunk_idx|
      offset = chunk_idx * CHUNK_SIZE
      Rails.logger.info "[#{self.class.name}] Translating lines #{offset + 1}–#{offset + chunk.size} / #{lines.size}"
      translate_chunk(chunk)
    end
  end

  private

  def translate_chunk(chunk)
    numbered    = chunk.each_with_index.map { |line, i| "#{i + 1}. #{line}" }.join("\n")
    full_prompt = "#{@prompt.strip}\n\n#{numbered}"

    response_text = call_api(full_prompt)
    translations  = parse_numbered_list(response_text)

    chunk.each_with_index.map do |arabic, i|
      { arabic: arabic, english: translations[i + 1] || "[Translation unavailable]" }
    end
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

  def call_api(_prompt)
    raise NotImplementedError, "#{self.class.name} must implement #call_api"
  end
end
