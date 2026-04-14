
# ============================================================
# Arabic PDF → Local HTML Translator (Rails Service Objects)
# ============================================================
#
# SETUP — add to Gemfile:
#   gem "anthropic"   # Claude API
#   gem "pdf-reader"  # PDF text extraction
#
# Then: bundle install
#
# Set environment variable (e.g. in .env via dotenv-rails):
#   ANTHROPIC_API_KEY=sk-ant-...
#
# USAGE:
#   result = ArabicPdfTranslatorService.call(
#     pdf_path: "path/to/file.pdf",
#     output_path: "public/translations/output.html",  # optional
#     prompt: TranslationPrompt::FORMAL                 # optional, defaults to DEFAULT
#   )
#   puts result.output_path   # where the HTML file was saved
#   puts result.pairs         # [{arabic: "...", english: "..."}, ...]


# ============================================================
# app/services/translation_prompt.rb
# ============================================================
# Change or add prompts here any time — just pass the constant
# (or any plain string) as the `prompt:` argument.
module TranslationPrompt
  # Standard faithful translation
  DEFAULT = <<~PROMPT
    You are a professional Arabic-to-English translator.
    Translate each numbered Arabic line below to English.
    Respond ONLY with the same numbered list in English — no preamble, no explanation.
    Preserve the original numbering exactly.
  PROMPT

  # Formal / legal tone
  FORMAL = <<~PROMPT
    You are a certified legal Arabic-to-English translator.
    Translate each numbered Arabic line with formal, precise language suitable for legal documents.
    Preserve all technical and legal terminology accurately.
    Respond ONLY with the same numbered list in English — no preamble, no explanation.
    Preserve the original numbering exactly.
  PROMPT

  # Simplified / plain English
  SIMPLIFIED = <<~PROMPT
    You are an Arabic-to-English translator specializing in plain language.
    Translate each Arabic line into simple, clear English that anyone can understand.
    Avoid jargon or overly formal phrasing.
    Respond ONLY with the same numbered list in English — no preamble, no explanation.
    Preserve the original numbering exactly.
  PROMPT

  # Medical / clinical tone
  MEDICAL = <<~PROMPT
    You are a medical Arabic-to-English translator.
    Translate each numbered Arabic line using accurate clinical and medical terminology.
    Respond ONLY with the same numbered list in English — no preamble, no explanation.
    Preserve the original numbering exactly.
  PROMPT
end
