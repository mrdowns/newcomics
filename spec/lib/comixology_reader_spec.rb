require 'fakeweb'
require'comixology_reader'

describe ComixologyReader, "when reading this week's entries" do
  before(:all) do
    FakeWeb.allow_net_connect = false

    FakeWeb.register_uri(
      :get, "http://www.comixology.com/thisweek/?f=COMIC", 
      :body => File.open("./spec/lib/comixology_page_1.html", "rb").read)
    FakeWeb.register_uri(
      :get, "http://www.comixology.com/thisweek/?f=COMIC&start=20", 
      :body => File.open("./spec/lib/comixology_page_2.html", "rb").read)
    FakeWeb.register_uri(
      :get, "http://www.comixology.com/thisweek/?f=COMIC&start=40", 
      :body => File.open("./spec/lib/comixology_page_3.html", "rb").read)

    @reader = ComixologyReader.new
    @comics = @reader.comics
  end

  it "should populate all the things" do
    expected = [
      Comic.new do 
        @title = 'Executive Assistant Iris #4 Cvr A Francisco'
        @image_url = 'http://cdn.comixology.com/2011/AUG11/thumbnails/AUG110831_t.jpg'
        @large_image_url = 'http://cdn.comixology.com/2011/AUG11/midsize/AUG110831_m.jpg' 
        @publisher = 'Aspen Comics'
      end,
      Comic.new do 
        @title = 'DC Universe: Online Legends #15'
        @image_url = 'http://cdn.comixology.com/2011/AUG11/thumbnails/AUG110177_t.jpg'
        @large_image_url = 'http://cdn.comixology.com/2011/AUG11/midsize/AUG110177_m.jpg' 
        @publisher = 'Dc Comics'
      end,
      Comic.new do 
        @title = 'Detective Comics (2011-) #2'
        @image_url = 'http://cdn.comixology.com/2011/AUG11/thumbnails/AUG110190_t.jpg'
        @large_image_url = 'http://cdn.comixology.com/2011/AUG11/midsize/AUG110190_m.jpg' 
        @publisher = 'Dc Comics'
      end,
      Comic.new do 
        @title = 'Transformers: Ongoing #27'
        @image_url = 'http://cdn.comixology.com/2011/AUG11/thumbnails/AUG110339_t.jpg'
        @large_image_url = 'http://cdn.comixology.com/2011/AUG11/midsize/AUG110339_m.jpg' 
        @publisher = 'Idw'
      end,
      Comic.new do 
        @title = 'Moon Knight #6'
        @image_url = 'http://cdn.comixology.com/2011/AUG11/thumbnails/AUG110627_t.jpg'
        @large_image_url = 'http://cdn.comixology.com/2011/AUG11/midsize/AUG110627_m.jpg' 
        @publisher = 'Marvel'
      end,
    ]

    expected.each do |comic|
      scraped = @comics.select { |c| c.title == comic.title }
      scraped.length.should eq(1)
      scraped[0].title.should eq(comic.title)
      #scraped[0].image_url.should eq(comic.image_url)
      scraped[0].large_image_url.should eq(comic.large_image_url)
      scraped[0].publisher.should eq(comic.publisher)
    end

  end
end

