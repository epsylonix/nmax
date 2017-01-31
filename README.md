#nmax

[![Build Status](https://travis-ci.org/epsylonix/nmax.svg?branch=master)](https://travis-ci.org/epsylonix/nmax)

Home: https://github.com/epsylonix/nmax

Bugs: https://github.com/epsylonix/nmax/issues

#Description
nmax is a simple program that takes in text data from the standart input
and outputs *N* top numbers found in the text to the standart output.

#Installation
    git clone https://github.com/epsylonix/nmax.git
    cd nmax
    gem build nmax.gemspec
    gem install nmax-0.0.1.gem

#Usage:
`cat sample_data_40GB.txt | nmax N`

##Notes:
* Input data is expected to be in ASCII or UTF-8 encoding.
* Output is sorted in ascending order
* Leading zeros are inored (00058 is converted to 58)
* Duplicate numbers are not removed

#License
nmax is released under the MIT License.
