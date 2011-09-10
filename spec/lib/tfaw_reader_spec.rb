require 'fakeweb'
require'tfaw_reader'

describe TfawReader, "when reading next week's entries" do
  before(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.tfaw.com/Arriving-This-Week", :body => File.open("./spec/lib/tfaw_page_1.html", "rb").read)
    FakeWeb.register_uri(:get,"http://www.tfaw.com/Arriving-This-Week/Search/_results_adultfilter_search=T/_results_available_search=allnobackorder/_results_end_date_search=%2B3+days/_results_limit_search=30/_results_ordercombo_search=title_asc/_results_start_at_search=30/_results_start_date_search=-4+days", :body => File.open("./spec/lib/tfaw_page_2.html", "rb").read)
    FakeWeb.register_uri(:get, "http://www.tfaw.com/Arriving-This-Week/Search/_results_adultfilter_search=T/_results_available_search=allnobackorder/_results_end_date_search=3%2Bdays/_results_limit_search=30/_results_order_search=title/_results_ordercombo_search=title_asc/_results_start_at_search=60/_results_start_date_search=-4%2Bdays", :body => File.open("./spec/lib/tfaw_page_3.html", "rb").read)

    @reader = TfawReader.new
    @comics = @reader.comics
  end

  it "should populate all the things" do
    expected = [
      Comic.new do 
        @title = '50 Girls 50 #4 (of 4)'
        @image_url = 'http://images.tfaw.com/covers_tfaw/100/ju/jul110509.jpg'
        @large_image_url = 'http://images.tfaw.com/covers_tfaw/200/ju/jul110509.jpg' 
        @publisher = 'Image Comics'
      end,
      Comic.new do 
        @title = '68 (Sixty Eight) #4 (of 4) (Cover A - Nat Jones & Jay Fotos)'
        @image_url = 'http://images.tfaw.com/covers_tfaw/100/ma/may110488.jpg'
        @large_image_url = 'http://images.tfaw.com/covers_tfaw/200/ma/may110488.jpg' 
        @publisher = 'Image Comics'
      end,
      Comic.new do 
        @title = 'Comics #2 Lucille Ball'
        @image_url = 'http://images.tfaw.com/covers_tfaw/100/ju/jun110906.jpg'
        @large_image_url = 'http://images.tfaw.com/covers_tfaw/200/ju/jun110906.jpg' 
        @publisher = 'Bluewater Productions'
      end,
    ]

    expected.each do |comic|
      scraped = @comics.select { |c| c.title == comic.title }
      scraped.length.should eq(1)
      scraped[0].title.should eq(comic.title)
      scraped[0].image_url.should eq(comic.image_url)
      scraped[0].large_image_url.should eq(comic.large_image_url)
      scraped[0].publisher.should eq(comic.publisher)
    end
  end

  it "shouldn't return a publisher for entries that don't have one" do
    comic = @comics.select { |c| c.title == "Clint #11" }
    comic.first.publisher.should eq('')
  end

  it "should figure out the large image url" do
    expected = [
      'http://images.tfaw.com/covers_tfaw/200/ju/jul110509.jpg',
      'http://images.tfaw.com/covers_tfaw/200/ma/may110488.jpg',
      'http://images.tfaw.com/covers_tfaw/200/ju/jun110906.jpg',
    ]

    urls = @comics.collect{|c| c.large_image_url}
    expected.each do |url|
      urls.should include url
    end
  end

  it "should get the image url, too" do
    expected = [
      'http://images.tfaw.com/covers_tfaw/100/ju/jul110509.jpg',
      'http://images.tfaw.com/covers_tfaw/100/ma/may110488.jpg',
      'http://images.tfaw.com/covers_tfaw/100/ju/jun110906.jpg',
    ]

    urls = @comics.collect{|c| c.image_url}
    expected.each do |url|
      urls.should include url
    end
  end

  it "should list the current titles" do
    expected = [
      '50 Girls 50 #4 (of 4)', 
      '68 (Sixty Eight) #4 (of 4) (Cover A - Nat Jones & Jay Fotos)',
      'Comics #2 Lucille Ball',
      'Complete Major Bummer Super Slacktacular! TPB',
      'Conspiracy of the Planet of the Apes HC',
      'G.I. Joe Special Missions TPB Vol. 04',
      'Garth Ennis Jennifer Blood #4',
      'Giant Size Little Lulu Vol. 4 TPB',
      'Infamous #2 Lindsay Lohan',
    ]

    titles = @comics.collect{|c| c.title}
    expected.each do |title|
      titles.should include title
    end
  end

  it "should list all the things, across pages" do
    @comics.should have(90).things
  end

end

