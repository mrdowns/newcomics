require 'fakeweb'
require'tfaw_reader'

describe TfawReader, "when reading next week's entries" do
  before(:all) do
    FakeWeb.allow_net_connect = false
    FakeWeb.register_uri(:get, "http://www.tfaw.com/Arriving-This-Week", :body => File.open("./spec/lib/tfaw_page_1.html", "rb").read)
    FakeWeb.register_uri(:get,"http://www.tfaw.com/Arriving-This-Week/Search/_results_adultfilter_search=T/_results_available_search=allnobackorder/_results_end_date_search=%2B3+days/_results_limit_search=30/_results_ordercombo_search=title_asc/_results_start_at_search=30/_results_start_date_search=-4+days", :body => File.open("./spec/lib/tfaw_page_2.html", "rb").read)
    FakeWeb.register_uri(:get, "http://www.tfaw.com/Arriving-This-Week/Search/_results_adultfilter_search=T/_results_available_search=allnobackorder/_results_end_date_search=3%2Bdays/_results_limit_search=30/_results_order_search=title/_results_ordercombo_search=title_asc/_results_start_at_search=60/_results_start_date_search=-4%2Bdays", :body => File.open("./spec/lib/tfaw_page_3.html", "rb").read)

    @reader = TfawReader.new
    @titles = @reader.titles
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
    
    expected.each do |title|
      @titles.should include title
    end
  end

  it "should list all the things, across pages" do
    @titles.should have(90).things
  end

end

