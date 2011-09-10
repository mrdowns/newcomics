class Comic
  attr_accessor :title, :image_url, :large_image_url, :publisher

  def initialize(&block)
    if block_given?
      instance_eval(&block)
    end
  end
end
