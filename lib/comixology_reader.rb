require 'nokogiri'
require 'open-uri'

# thumbnail image format: YYYY/MMMdd/thumbnails/SKU_t.jpg
# midsize image format: YYYY/MMMdd/midsize/SKU_m.jpg
# large image format: YYYY/MMMdd/SKU.jpg
class ComixologyReader
  def initialize
    @comics = Array.new
    @base_page = 'http://www.comixology.com/thisweek/'
    read_page @base_page + '?f=COMIC'
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
      querystring = link['href']
      href = @base_page + querystring 
      read_page href 
    end
  end

  def try_to_read(href)
    Nokogiri::HTML(open(href))
  rescue
    nil #couldn't open, just swallow
  end

  def next_link(doc)
    links = doc.css("div#browse > div#items > span > a")
    next_links = links.select { |l| l.text =~ /Next/ }
    next_links.nil? ? nil : next_links.first
  end

  def add_books(doc)
    results = doc.css("table#listings")
    values = []
    results.each do |r|
      title = parse_title(r)
      large_image_url = parse_large_image_url(r)
      publisher = parse_publisher(r)

      comic = Comic.new do
        @title = title
        @large_image_url = large_image_url
        @publisher = publisher
      end
      values << comic if !comic.large_image_url.nil?
    end
    @comics.concat(values)
  end

  def parse_title(result_element)
    title_element = result_element.css('div#title > a:last-child')
    title = title_element.nil? ? nil : title_element.text
    title
  end

  def parse_large_image_url(result_element)
    img_element = result_element.css('td#image > a > img').first
    return '' if img_element.nil?
    src = img_element["src"]
    if(src =~ /no-image\.gif/) do
      return "http://cdn.comixology.com/midsize/no-image.gif"
    end
    src =~ /cdn\.comixology\.com\/(\w+)\/(\w+)\/thumbnails\/(\w+)_t\.jpg/
    year = $1
    monthday = $2
    sku = $3
    "http://cdn.comixology.com/#{year}/#{monthday}/midsize/#{sku}_m.jpg"
  end

  def parse_publisher(result_element)
    icon_element = result_element.css('span#icon > a > img').first
    return if icon_element.nil?
    src = icon_element["src"]
    src =~ /cdn\.comixology\.com\/xtras\/icons\/([a-zA-Z0-9-]+)\.(\w+)/
    return if $1.nil?
    $1.sub('-', ' ').titleize
  end
end
