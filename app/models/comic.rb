class Comic
  attr_accessor :title, :image_url

  def large_image_url
    image_url.sub("/100/", "/200/")
  end
end
