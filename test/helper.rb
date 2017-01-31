##
# utility methods and classes
# used for testing purposes
module Helper

  # returns StringIO object 
  # with enforced ASCII_8BIT encoding
  def byte_string_io(str)
    s = StringIO.new(str)
    s.set_encoding(Encoding::ASCII_8BIT)
  end

  # Mock File for testing.
  # Only read(buffer_size) method is implemented/
  # This is an abstract class
  # (shouldn't be used)
  class MockFile
    def initialize(*_args, **_kwargs)
      @leftover_chars = ''
      @chars_read = 0
    end
    
    def read(buffer_size)
      # file size control lies on get_output
      output_buffer = ''

      # fill the buffer up to buffer_size if possible
      while @leftover_chars.length < buffer_size
        output_buffer = get_output
        break if output_buffer.empty?
        @leftover_chars += output_buffer
      end
      
      output_buffer = @leftover_chars[0..buffer_size-1]
      
      unless output_buffer.empty?
        if @leftover_chars.length > buffer_size
          @leftover_chars = @leftover_chars[buffer_size..-1]
        else 
          @leftover_chars = ''
        end
        output_buffer.force_encoding(Encoding::ASCII_8BIT)
        return output_buffer
      end

      return nil
    end
    
    private
    def get_output(*_args)
      raise NotImplementedError
    end

    def save(*_args)
      raise NotImplementedError
    end
  end

  # Mock File with (pseudo) random content
  # Outputs mixed random numbers and unicode characters 
  # Keeps the list of top n largest numbers
  # Random seed is controlled with random_seed
  # to keep tests reproducible 
  #
  # Space requirements are constant an small
  # (doesn't consume min_file_size memory)
  class MockFileNumberGenerator < MockFile
    attr_reader :top_numbers

    def initialize(min_file_size:, n:, numbers_range: 10**1000 - 1, random_seed: 646546879)
      @numbers_range = numbers_range
      @n = n
      # file size in bytes (there will be fewer in unicode chars than bytes)
      @min_file_size = min_file_size
      # support seeding the random number generator
      # to generate reproducible test data
      @random_seed = random_seed
      srand @random_seed

      @top_numbers = NMax::SortedArray[]
      @chars_read = 0
      super
    end
    
    # saves the content of this Mock File to an actual file
    # Doesn't "rewind" therefore the characters that have been read
    # won't be written to a file
    def save(filename)
      File.open(filename, 'w') do |f|  
        while buf = read(8192) do
          buf.force_encoding(Encoding::UTF_8)
          f.write(buf)
        end
      end
    end
    
    private
    # generate random string from a subset if unicode chars (doesn't include digits)
    # length of generated string <= len
    def _rand_unicode(len)
      out = (1..rand(2...len)).map {[9312 + rand(1811)].pack('U*')}.join
      return out
    end

    # generates content using digits and unicode characters.
    # To simplify this function
    # the generated output may not be min_file_size bytes exactly
    # (can be larger by no more than output.length)
    # This is not important for the way it is used here 
    def get_output
      if @chars_read < @min_file_size
        number = rand(@numbers_range)
        # remeber top @n generated numbers
        begin
          if @top_numbers.length < @n
            @top_numbers << number
          elsif number > @top_numbers[0]
            @top_numbers.shift
            @top_numbers << number
          end
        rescue ArgumentError
          @top_numbers << number
        end

        output = _rand_unicode(10) + number.to_s + _rand_unicode(10) + "\n" * rand(2)
        
        output.force_encoding(Encoding::ASCII_8BIT)
        @chars_read += output.length

        return output
      end

      return ''

    end
  end
  
  def nmax_with_buffer(input, buffer)
    f = byte_string_io(input)
    output = []
    NMax.next_number(f, buffer)  {|n| output << n}
    output 
  end
  
  module_function :byte_string_io, :nmax_with_buffer
end
