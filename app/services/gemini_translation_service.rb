class GeminiTranslationService < BaseTranslationService
  MODEL = "gemini-2.5-flash"

  def translate(input_data, prompt: "")
    pdf_path = input_data.first
    api_key = ENV.fetch("GEMINI_API_KEY")
    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:generateContent?key=#{api_key}")

    # Read and Encode the PDF to Base64
    file_data = Base64.strict_encode64(File.read(pdf_path))

    payload = {
      contents: [ {
        parts: [
          { text: "Extract the Arabic text from this PDF and translate it line-by-line into English. Return ONLY a JSON array of objects with 'arabic' and 'english' keys. Ensure the 'arabic' text is in correct logical order (not reversed)." },
          { inline_data: { mime_type: "application/pdf", data: file_data } }
        ]
      } ],
      generationConfig: {
        responseMimeType: "application/json",
        maxOutputTokens: 8000
      }
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri, { "Content-Type" => "application/json" })
    request.body = payload.to_json

    response = http.request(request)
    body = JSON.parse(response.body)

    # Parse the JSON string returned by Gemini into a Ruby Array
    raw_json = body.dig("candidates", 0, "content", "parts", 0, "text")
    JSON.parse(raw_json, symbolize_names: true)
  end
end
