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
    @base_url = 'http://www.faqs.org/docs/artu/'
    url = 'http://www.faqs.org/docs/artu/index.html'
    html = run_shell_command "curl -s #{url}"
    doc = Nokogiri::HTML html
    xs = []  # the sections
    frontmatter_section = {
      title: 'Frontmatter',
      articles: [ { title: 'Title Page', path: titlepage(doc) }, { title: 'Dedication', path: dedication(doc) } ]
    }
    xs << frontmatter_section
    doc.search('.toc a').select {|a| a['href'] =~ /html$/}.each {|a|

      if a.inner_text =~ /^Glossary/
        xs << { title: "Appendix", articles:[ ] }
      elsif a.inner_text =~ /^Rootless/
        xs << { title: "Unix Koans", articles:[ ] }
      end

      if a[:href] =~ /(preface|chapter)\.html/ 
        # looks like a section
        xs << {
          title: a.inner_text, 
          articles:[
            {
              title: a.inner_text.gsub(/\s{2,}/, ' ').strip, 
              path: save_article(a[:href])
            }
          ]
        }
      else 
        # add an article
        xs.last[:articles] << {title: a.inner_text.gsub(/\s{2,}/, ' ').strip, path: save_article(a[:href])}
      end
    }
    xs
  end
 
  def titlepage(doc) 
    path = 'articles/titlepage'
    content = utf8 doc.at('.titlepage').inner_html 
    File.open("#{output_dir}/#{path}", 'w'){|f| f.puts content}
    path
  end

  def dedication(doc) 
    path = 'articles/dedication'
    content = utf8 doc.at('.dedication').inner_html
    File.open("#{output_dir}/#{path}", 'w'){|f| f.puts content}
    path
  end

  def save_article filename
    path = "articles/#{filename}"
    return path if File.size?("#{output_dir}/#{path}")
    url = @base_url + filename
    html = run_shell_command("curl -s #{url}")
    doc = Nokogiri::HTML html

    # strip off navigation
    doc.search(".navheader").map &:remove
    doc.search(".navfooter").map &:remove

    # images have relative paths, so fix them
    article_doc.search("img[@src]").each {|img|
      if img['src'] =~ %r{^/}
        img['src'] = @base_url + img['src']
      end
    }

    content = utf8 doc.at('body').inner_html
    File.open("#{output_dir}/#{path}", 'w'){|f| f.puts content}
    path
  end

  def utf8 content
    # These pages seem to be encoded in iso-8859-1
    content = content.force_encoding('iso-8859-1')
    content.encode 'utf-8', undef: :replace, invalid: :replace
  end
end

#DocsOnKindle.noclobber = true

Unix.generate



