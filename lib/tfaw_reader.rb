require 'nokogiri'
require 'open-uri'

class TfawReader
  def initialize
    @titles = Array.new
    # where do you put a constant like this?
    read_page 'http://www.tfaw.com/Arriving-This-Week'
  end

  def titles
    @titles
  end

  private

  def read_page(href)
    @read_count ||= 0
    @read_count += 1
    doc = try_to_read(href) or return
    add_titles doc
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

  def add_titles(doc)
    results = doc.css("#results_form table a.boldlink img")
    values = results.collect { |link| link["alt"] }
    @titles.concat(values)
  end

end
  

