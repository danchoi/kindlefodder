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
    xs = []
    doc.search('.toc a').select {|a| a['href'] =~ /html$/}.each {|a|
      if a[:href] =~ /(preface|chapter)\.html/ 
        # looks like a section
        xs << {
          title: a.inner_text, 
          articles:[
            {
              title: a.inner_text.strip, 
              href: a[:href]
            }
          ]
        }

      else 
        # add an article
        xs.last[:articles] << {title: a.inner_text, href: a[:href]}
      end
    }
    puts xs.to_yaml
  end
 

end

Unix.new.extract_sections 
#Unix.generate



