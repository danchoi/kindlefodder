=begin

http://www.faqs.org/docs/artu/index.html

=end

require 'docs_on_kindle'

class Unix < DocsOnKindle

  def get_source_files
    sections = extract_sections
    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end

  def document 
    {
      'title' => 'The Art of Unix Programming',
      'author' => 'Eric Steven Raymond',
      'cover' => nil,
      'masthead' => nil
    }
  end

  def extract_sections
    url = 'http://www.faqs.org/docs/artu/index.html'
    doc = Nokogiri::HTML `curl -s #{url}`
    doc.search('.toc a').select {|a| a['href'] =~ /html$/}.map {|a|
      puts a
    }
  end
 

end

Unix.new.extract_sections 
#Unix.generate



