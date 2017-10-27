require "minitest/autorun"

def create_tempfile(content, filename="")
  Tempfile.new(filename).tap do |f|
    f.write(content)
    f.close
  end
end
