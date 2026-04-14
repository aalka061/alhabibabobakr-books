class PdfExtractorService
  def self.extract(pdf_path)
    # We return the path itself because Gemini 2.5 Flash
    # can read the PDF directly without broken text extraction.
    [ pdf_path ]
  end
end
