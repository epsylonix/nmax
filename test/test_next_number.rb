require 'minitest/autorun'
require_relative "../lib/nmax"
require_relative "helper"

describe NMax do
  describe "next_number" do
    it "reads numbers with buffer_size=1" do
      assert_equal ['1234567','890'], Helper::nmax_with_buffer('1234567 \n 890', 1)
      assert_equal ['1234567','890'], Helper::nmax_with_buffer('sdsads1234567 \n 890sdads', 1)
    end

    it "reads numbers with buffer_size==length of the number" do
      assert_equal ['1234567','890'], Helper::nmax_with_buffer('1234567 \n 890', 7)
      assert_equal ['1234567','890'], Helper::nmax_with_buffer('asqdfre1234567 \n 890', 7)
    end

    it "reads numbers with buffer_size==almost full file size" do
      assert_equal ['1234567','80'], Helper::nmax_with_buffer('1234567 80', 9)
    end

    it "reads numbers when buffer window splits them" do
      assert_equal ['1234567','890'], Helper::nmax_with_buffer('1234567 890', 3)
    end
    
    it "reads numbers with buffer_size=full file size" do
      assert_equal ['1234567','890'], Helper::nmax_with_buffer('1234567 890', 11)
    end
    
    it "reads numbers with unicode symbols in the file" do
      assert_equal ['1234567','890','100000'],
                   Helper::nmax_with_buffer('as☺dcz fdsda☆d adwd☆dwыва1234567 awdawd890\n\nsdads☆100000', 1000)
    end
  end
end