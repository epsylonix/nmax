require_relative "../lib/nmax"
require_relative "helper"
require 'minitest/autorun'

describe NMax do

	describe "SortedArray" do
		it "sorts an array on creation" do
			ary = Array.new(100) { rand(1000)}
			s_ary = NMax::SortedArray.new(ary)
			assert_equal ary.sort, s_ary
		end

		it "keeps order when appending elements" do
			ary = Array.new(1000) { rand(10000)}
			s_ary = NMax::SortedArray[]
			ary.each {|e| s_ary << e }
			assert_equal ary.sort, s_ary
		end
	end

	describe "nmax" do
		it "collects all 1-digit numbers" do
			f = Helper::byte_string_io('8 9 1 5 6 7 2 3 4 0')
			assert_equal [0,1,2,3,4,5,6,7,8,9], NMax.nmax(100,f)
		end

		it "collects N top 1-digit numbers" do
			f = Helper::byte_string_io('8 9 1 5 6 7 2 3 4 0')
			assert_equal [7,8,9], NMax.nmax(3,f)
		end

		it "collects N top numbers on a small sample" do
			f = Helper::byte_string_io('82353 93532 18765 54346 63454 7754 24565 34534 4424 0')
			assert_equal [34534,54346,63454,82353,93532], NMax.nmax(5,f)
		end

		it "keeps duplicate numbers" do
			f = Helper::byte_string_io('82353 63454 93532 18765 54346 63454 82353 7754 24565 34534 4424 0')
			assert_equal [63454,63454,82353,82353,93532], NMax.nmax(5,f)
		end

		it "collects 1000 top 30-digit numbers on a 10Mb sample" do
			f = Helper::MockFileNumberGenerator.new(
                           min_file_size: 83886080, 
												   n: 1000, 
												   numbers_range: 10**30 - 1
												  )
			assert_equal f.top_numbers, NMax.nmax(1000, f)
		end

		it "collects 1000 top 1000-digit numbers on a 10Mb sample" do
			f = Helper::MockFileNumberGenerator.new(
                           min_file_size: 83886080, 
												   n: 1000, 
												   numbers_range: 10**1000 - 1,
												   random_seed: 1456354
												  )
			assert_equal f.top_numbers, NMax.nmax(1000, f)
		end

	end

 end