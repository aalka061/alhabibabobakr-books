# ============================================================
# app/services/arabic_pdf_translator_service.rb
# ============================================================
class ArabicPdfTranslatorService
  Result = Struct.new(:output_path, :pairs, :error, keyword_init: true) do
    def success? = error.nil?
  end

  PROVIDERS = {
    claude: ClaudeTranslationService,
    gemini: GeminiTranslationService
  }.freeze

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def initialize(pdf_path:, output_path: nil, prompt: nil, provider: :claude)
    @pdf_path    = pdf_path
    @output_path = output_path || default_output_path
    @prompt      = prompt || TranslationPrompt::SIMPLIFIED
    @provider    = provider
  end

  def call
    lines = PdfExtractorService.extract(@pdf_path)
    return Result.new(error: "No text extracted — PDF may be image-based") if lines.empty?

    service = PROVIDERS.fetch(@provider) { raise "Unknown provider: #{@provider}. Use :claude or :gemini" }
    pairs   = service.translate(lines, prompt: @prompt)
    HtmlExporterService.export(pairs: pairs, output_path: @output_path)

    Result.new(output_path: @output_path, pairs: pairs)
  rescue => e
    Result.new(error: e.message)
  end

  private

  def default_output_path
    basename = File.basename(@pdf_path, ".*")
    FileUtils.mkdir_p(Rails.root.join("public/translations"))
    Rails.root.join("public/translations", "#{basename}_translated.html").to_s
  end
end
