module NMax

  # the largest expected number from the stdin has no more than 1000 digits.
  # it will be stored as BigNum and the max size in bytes will be MAX_INT_SIZE
  MAX_INT_SIZE = (10**1000 - 1).size

  ##
  # nmax main application object.  When invoking +nmax+ from the
  # command line, a NMax::Application object is created and run.

  class Application
    def initialize(argv)
      @N = _verify_options(argv)
    end

    # Run the nmax application. 
    def run(f=$stdin)
      output = NMax::nmax(@N, $stdin)
      output.each { |number| $stdout.puts number }
    end

    def _verify_options(argv)
      n = nil
      if argv.empty?
        self.class._print_help
        exit(0)
      elsif argv.length != 1
        $stdout.puts 'nmax: nmax takes exactly one argument'
        exit(1)
      end

      begin
        n = Integer(argv[0])
      rescue ArgumentError
        $stdout.puts "nmax: invalid argument, an integer is required"
        exit(1)
      end

      if n < 0
        $stdout.puts 'nmax: invalid argument, N can\'t be negative!'
        exit(1)
      end
      
      exit(0) if n.zero? # no output is requred if N==0

      # Do a very rough check if the N is too big
      # This check is a crude approximation, doesn't guarantee we won't run out of memory
      mem = self.class._available_memory
      if mem and mem < MAX_INT_SIZE * n + READ_CHUNK_SIZE
        # when `free` didn't give us available memory, run anyway
        $stdout.puts 'nmax: there may not be enough memory avaliable for completion with that N.'
        $stdout.puts 'Please use a lower number.'
        exit (1)
      end

      return n
    end
    
    def self._print_help
      $stdout.puts 'Usage: cat sample_data_40GB.txt | nmax N'
      $stdout.puts '  N - the number of the largest numbers to collect from the input text'
      $stdout.puts '  * Leading zeros are ignored'
      $stdout.puts '  * Duplicate numbers are not removed'
      $stdout.puts '  * Output is sorted in ascending order.'
      $stdout.puts '  * Output is one number a line'
    end

    # Returns available (free) system memory in bytes
    # Windows: returns a value that allows the program to run (a reasonable guess of 1Gb)
    # Should be easy enough 
    def self._available_memory
      begin
        Integer(`free`.split(' ')[9]) * 1024
      rescue Errno::ENOENT
        # if that fails (on Windows for, example)
        # return nil
        nil
      end
    end

  end

end