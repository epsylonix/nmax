require_relative "../lib/nmax"
require_relative "helper"
require 'minitest/autorun'

describe NMax::Application do
  def setup
    $stdout = StringIO.new
    #$stdout = Helper::MockSTDOUT.new
  end

  def teardown
    $stdout = STDOUT
  end

  it "prints help when called with no arguments" do
    assert_raises(SystemExit) { NMax::Application.new([]) }

    app_output = $stdout.string
    $stdout.flush
    NMax::Application._print_help
    assert_equal(app_output,  $stdout.string)
  end

  it "exits if given more than one argument" do
    assert_raises(SystemExit) { NMax::Application.new(['5','8']) }
  end

  it "exits if an argument is not a number" do
    assert_raises(SystemExit) { NMax::Application.new(['asd']) }
  end

  it "exits if N is too large" do
    assert_raises(SystemExit) { NMax::Application.new([(10**1000).to_s]) }
  end

  it "exits if N<0" do
        #this would fail on Windows
    assert_raises(SystemExit) { NMax::Application.new([(-1).to_s]) }
  end

  it "works fine with a correct argument" do
    $stdin = Helper::byte_string_io('10вфыв ыв30 40 sd20 sda1000d')
    app = NMax::Application.new([3])
    app.run
    assert_equal("30\n40\n1000\n", $stdout.string)
    $stdin = STDIN
  end
end