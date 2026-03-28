require "mechanize"

class ScraperService
  BOOKS_URL = "https://www.alhabibabobakr.com/books/"

  HIJRI_MONTHS = [
    "محرم", "صفر", "ربيع الأول", "ربيع الثاني",
    "جمادى الأولى", "جمادى الآخرة", "جمادى الآخر", "رجب", "شعبان",
    "رمضان", "شوال", "ذي القعدة", "ذو القعدة", "ذي الحجة", "ذو الحجة", "ذي الحجه"
  ]

  ARABIC_DAY_MAP = {
    "الأول" => 1, "الثاني" => 2, "الثالث" => 3, "الرابع" => 4, "الخامس" => 5,
    "السادس" => 6, "السابع" => 7, "الثامن" => 8, "التاسع" => 9, "العاشر" => 10,
    "الحادي عشر" => 11, "الثاني عشر" => 12, "الثالث عشر" => 13, "الرابع عشر" => 14, "الخامس عشر" => 15,
    "السادس عشر" => 16, "السابع عشر" => 17, "الثامن عشر" => 18, "التاسع عشر" => 19, "العشرين" => 20,
    "الحادي والعشرين" => 21, "الثاني والعشرين" => 22, "الثالث والعشرين" => 23, "الرابع والعشرين" => 24,
    "الخامس والعشرين" => 25, "السادس والعشرين" => 26, "السابع والعشرين" => 27, "الثامن والعشرين" => 28,
    "التاسع والعشرين" => 29, "الثلاثين" => 30
  }

  def self.call(start_page = 1)
    agent = Mechanize.new
    agent.user_agent_alias = "Mac Safari"

    begin
      # Jump to specific page if resuming
      target_url = start_page > 1 ? "#{BOOKS_URL}page/#{start_page}/" : BOOKS_URL
      current_page = agent.get(target_url)
      page_count = start_page

      loop do
        puts "--- Processing Page: #{page_count} ---"
        items = current_page.search("#itemContainer li.clearfix")

        items.each do |item|
          title_link = item.at("strong a")
          next unless title_link
          book_url = title_link["href"]

          next if Book.exists?(url: book_url)

          image_url = item.at("img") ? item.at("img")["src"] : nil
          pub_date  = item.at(".date") ? item.at(".date").text.strip : nil
          pdf_url   = item.at("a.download") ? item.at("a.download")["href"] : nil

          # Fix for "nil" Category error
          raw_cat = item.at(".category")&.text&.strip
          # If category text is empty or just says the label, use "General"
          cat_name = (raw_cat.present? && raw_cat != "التصنيف:") ? raw_cat.split("،").first.strip : "General"
          category = Category.find_or_create_by!(name: cat_name)

          scrape_book_detail(agent, book_url, title_link.text.strip, category, image_url, pub_date, pdf_url)
        end

        next_link = current_page.link_with(text: /التالي|Next|>/)
        break unless next_link

        current_page = next_link.click
        page_count += 1
        sleep 1
      end
    rescue => e
      puts "Scraper stopped at page #{page_count || 'unknown'}: #{e.message}"
    end
  end

  private

  def self.scrape_book_detail(agent, url, title, category, img, pub_date, pdf)
    begin
      page = agent.get(url)

      # Use Safe Navigation to find the text container
      article_node = page.search("article").first || page.search(".entry-content").first

      if article_node.nil?
        puts "Skipping #{title}: Content area not found."
        return
      end

      full_content = article_node.text.strip

      # 1. Identify Month
      reading_month = HIJRI_MONTHS.find { |m| full_content.include?(m) }
      reading_month = "جمادى الآخرة" if reading_month == "جمادى الآخر"
      reading_month = "ذي الحجة"     if reading_month == "ذي الحجه"
      reading_month = "ذي القعدة"    if [ "ذو القعدة", "ذي القعده" ].include?(reading_month)

      # 2. Identify Day
      day_val = nil
      if reading_month
        digit_match = full_content.match(/(\d{1,2})\s+#{reading_month}/)
        if digit_match
          day_val = digit_match[1].to_i
        else
          day_word = ARABIC_DAY_MAP.keys.find { |word| full_content.include?(word) }
          day_val = ARABIC_DAY_MAP[day_word] if day_word
        end
      end

      # 3. Hijri Death String
      death_match = full_content.match(/(?:المتوفى|توفي|انتقل)\s+([^هـ]+هـ)/)
      hijri_str = death_match ? death_match[1].strip : nil

      Book.create!(
        title: title,
        description: full_content,
        url: url,
        image_url: img,
        pdf_url: pdf,
        published_at: pub_date,
        hijri_death_date: hijri_str,
        reading_month: reading_month,
        day_of_month: day_val,
        category: category
      )

      puts "Saved: #{title} [#{day_val} #{reading_month}]"
      sleep 0.5
    rescue => e
      puts "Error on book #{url}: #{e.message}"
    end
  end
end
