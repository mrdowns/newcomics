require 'tfaw_reader'

class ComicsController < ApplicationController
  def index
    reader = TfawReader.new
    @comics = reader.comics
  end
end
