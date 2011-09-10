require 'nokogiri'
require 'open-uri'


class TfawReader
  def initialize
    @comics = Array.new
    # where do you put a constant like this?
    read_page 'http://www.tfaw.com/Arriving-This-Week'
  end

  def comics
    @comics
  end

  private

  def read_page(href)
    @read_count ||= 0
    @read_count += 1
    doc = try_to_read(href) or return
    add_books doc
    link = next_link doc
    unless link.nil?
      href = link['href']
      href = 'http://www.tfaw.com' + href if href.start_with?('/')
      read_page href 
    end
  end

  def try_to_read(href)
    Nokogiri::HTML(open(href))
  rescue
    nil #couldn't open, just swallow
  end

  def next_link(doc)
    links = doc.css("div.small-corners-light a.regularlink")
    next_links = links.select { |l| l.text =~ /[Nn]ext ([Pp]age )?>>/ }
    next_links.nil? ? nil : next_links.first
  end

  def add_books(doc)
    results = doc.css("#results_form > table > tr")
    values = []
    results.each do |r|
      images = r.css("a.boldlink img.cover-image")
      next if images.nil? or images.length < 1
      publisher = parse_publisher(r)

      img = images.first
      comic = Comic.new do
        @title = img["alt"]
        @image_url = img["src"]
        @large_image_url = img["src"].sub("/100/", "/200/")
        @publisher = publisher
      end
      values << comic
    end
    @comics.concat(values)
  end

  def parse_publisher(table_row)
    publisher_element = table_row.css("td:nth-child(3) div:nth-child(2) i")
    return '' if publisher_element.nil? || publisher_element.length == 0
    #if there's a publisher, it'll have a semicolon. If there is none,
    #publisher is empty
    return '' if !publisher_element.first.text.include? ";"
    publisher_element.first.text[/^[^;]+/, 0]
  end

end
  

