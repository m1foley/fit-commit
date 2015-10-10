require "minitest/autorun"

def create_tempfile(filename, content)
  Tempfile.new(filename).tap do |f|
    f.write(content)
    f.close
  end
end
