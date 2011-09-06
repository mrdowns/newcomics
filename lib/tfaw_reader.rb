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
    #results = doc.css("#results_form table a.boldlink img")
    results = doc.css("#results_form > table > tr")
    values = []
    results.each do |r|
      images = r.css("a.boldlink img.cover-image")
      next if images.nil? or images.length < 1

      img = images.first
      comic = Comic.new
      comic.title = img["alt"]
      comic.image_url = img["src"]
      values << comic
    end
    #values = results.collect { |link| link["alt"] }
    @comics.concat(values)
  end

end
  

