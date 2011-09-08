require 'spec_helper'

describe Comic do
  it "should sub 200 for 100 for large image" do
    comic = Comic.new
    comic.image_url = "something/100/something"

    comic.large_image_url.should eq("something/200/something")
  end
end
