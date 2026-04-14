
# ============================================================
# app/services/html_exporter_service.rb
# ============================================================
require "cgi"

class HtmlExporterService
  def self.export(pairs:, output_path:)
    new(pairs: pairs, output_path: output_path).export
  end

  def initialize(pairs:, output_path:)
    @pairs       = pairs
    @output_path = output_path
  end

  def export
    FileUtils.mkdir_p(File.dirname(@output_path))
    File.write(@output_path, render_html)
    @output_path
  end

  private

  def render_html
    rows = @pairs.map do |pair|
      <<~HTML
        <div class="pair">
          <p class="arabic">#{CGI.escapeHTML(pair[:arabic])}</p>
          <p class="english">#{CGI.escapeHTML(pair[:english])}</p>
        </div>
      HTML
    end.join("\n")

    <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Arabic / English Translation</title>
        <style>
          body {
            font-family: Georgia, serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 0 20px;
            background: #fafafa;
            color: #222;
          }
          h1 {
            font-size: 1.4rem;
            color: #555;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
            margin-bottom: 30px;
          }
          .pair {
            margin-bottom: 24px;
            padding: 16px 20px;
            background: #fff;
            border-left: 4px solid #4a6fa5;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
          }
          .arabic {
            direction: rtl;
            text-align: right;
            font-size: 1.15rem;
            font-weight: bold;
            color: #1a2e5a;
            margin: 0 0 10px 0;
            line-height: 1.8;
          }
          .english {
            direction: ltr;
            text-align: left;
            font-size: 1rem;
            font-style: italic;
            color: #444;
            margin: 0;
            padding-left: 12px;
            border-left: 2px solid #e0e0e0;
            line-height: 1.7;
          }
        </style>
      </head>
      <body>
        <h1>Arabic / English Translation</h1>
        #{rows}
      </body>
      </html>
    HTML
  end
end
