#
# Author: Rohith 
# Date:   2014-03-02 17:22:15
# Last Modified by:   Rohith
#
# vim:ts=4:sw=4:et
#
module OptionsDSL
module Utils

    def validate_directory(directory)
      raise ArgumentError, "the directory #{directory} does not exist" unless File.exists? directory
      raise ArgumentError, "the directory #{directory} is not a directory" unless File.directory? directory
      raise ArgumentError, "the directory #{directory} is not readable" unless File.readable? directory
      directory
    end

    def validate_options_file(filename)
      raise ArgumentError, "the filename #{filename} does not exists" unless File.exists? filename
      raise ArgumentError, "the filename #{filename} is not readable" unless File.readable? filename
      raise ArgumentError, "the filename #{filename} is not a regular file" unless File.file? filename
      filename
    end

end
end