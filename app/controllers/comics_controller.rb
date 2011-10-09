require 'comixology_reader'

class ComicsController < ApplicationController
  def index
    reader = ComixologyReader.new
    @comics = reader.comics
  end
end
