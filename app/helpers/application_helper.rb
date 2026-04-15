module ApplicationHelper
  # When the app sits behind TLS termination, X-Forwarded-Proto may be https while
  # request.base_url is still http:// unless config.assume_ssl is set. These helpers
  # force https for Open Graph URLs so crawlers (WhatsApp, Telegram, etc.) get valid previews.
  def open_graph_base_url
    base = request.base_url
    if forwarded_proto_https? && base.start_with?("http://")
      base.sub(/\Ahttp:/, "https:")
    else
      base
    end
  end

  def open_graph_page_url
    url = request.original_url
    if forwarded_proto_https? && url.start_with?("http://")
      url.sub(/\Ahttp:/, "https:")
    else
      url
    end
  end

  private

  def forwarded_proto_https?
    request.headers["X-Forwarded-Proto"].to_s.casecmp("https").zero?
  end
end
