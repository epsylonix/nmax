module NMax

# The input stream is read in chunks of READ_CHUNK_SIZE length (bytes)
# Low values decrease performance.
# Optimal value is dependant on OS, filesystem and hardware.  
READ_CHUNK_SIZE = 8192 


# Array that ramains sorted after adding/removing elements.
# Only methods required for the task are implemented.
# SortedArray can and will become unsorted
# when other Array methods are used on it!
class SortedArray < Array
	def self.[] (*array)
		SortedArray.new(array)
	end

	def initialize(array = nil)
		super(array.sort) if array
	end

	def << value
		insert(less_equal_index(value), value)
	end

	alias push <<

	# O(log2(n))
	def less_equal_index(value)
		l,r = 0, length-1
		while l <= r
			m = (r+l) / 2
			if value < self[m]
				r = m - 1
			else
				l = m + 1
			end
		end
		l
	end
end

# iterator that continuously reads specified file or STDIN
# in chunks of buffer_size (default value is READ_CHUNK_SIZE)
# and yields found numbers as strings
def next_number(f=STDIN, buffer_size=READ_CHUNK_SIZE)
	raise ArgumentError, "Buffer size can't be less than 1" unless buffer_size >= 1
	# Assumed that [Number of digits] <= [Max length of String] 
	buffer_str, partial_number = '', ''

	buffer_str.force_encoding(Encoding::ASCII_8BIT) # to deal with UTF-8
	# in UTF-8 chars can ocuppy multiple bytes
	# while reading X bytes it is likely we'll read half a character
	# But we only care about digits and those are one-byte-a-char
	# In UTF-8 code points of ASCII characters can't be a part of any other character
	# so we can ignore multibyte characters - there won't be false digits there
	# But that's not the case for UTF-16 so we don't support it here
	#
	# f.gets(buffer_size) seems to work fine with unicode 
	# and doesn't corrupt multibyte characters 
	# but benchmarking shows it is about 25% slower

	number_parts, m = nil, nil
	re = Regexp.new('\d+')
	while buffer_str = f.read(buffer_size)
		# we're reading by fixed amounts so we have to deal
		# with numbers being split by buffer's window
		number_parts = buffer_str.to_enum(:scan, re)
		
		if not number_parts.any?
			# this buffer_str didn't contain any digits
			if not partial_number.empty?
				yield partial_number; 
				partial_number = '' 
			end
		else
			number_parts.each do |number|
				m = Regexp.last_match
				# deal with a part of number (if any) from prev read
				if not partial_number.empty?
					if m.begin(0) == 0
						number = partial_number + number
					else
						yield partial_number; 
						partial_number = ''
					end 
				end
				if not m.end(0) == buffer_str.length
					yield number; 
					partial_number = ''
				else # else number continues to the next read
					 partial_number = number
				end 
			end 
		end
	end
	# when a number ends at the end of a file
	# it doesn't gets yielded above (it might be continued in the next read)
	# and as there is no next read it remains in partial_number
	yield partial_number unless partial_number.empty?
end

# outputs to STDOUT top n largest numbers from a file or STDIN.
# * numbers are sorted in ascending order
# * duplicate numbers are not removed
# * leading zeros are ignored (ex.: 00057 => 57)
def nmax(n, f=STDIN)
	ints = SortedArray[] # output Array
	# Ruby doesn't have native Heaps that might be used here
	# Heaps implemented using Ruby are much slower than a plain Array (benchmarked)
	# so we compromise with a SortedArray

	next_number(f) do |str_number|
		# ignoring leading zeros
		number = str_number.to_i 
		begin
			if ints.length >= n
				if number > ints[0]
					ints.push(number)
					ints.shift
				end
			else
				ints.push(number)
			end
		rescue ArgumentError
			ints.push(number)
		end
	end
	
	ints
end

module_function :next_number, :nmax

end