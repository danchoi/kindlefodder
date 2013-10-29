=begin

http://svnbook.red-bean.com/en/1.7/index.html

=end

require 'kindlefodder'

class SVN < Kindlefodder

  def get_source_files
    sections = extract_sections
    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end

  def document 
    {
      'title' => 'The Subversion Book',
      'author' => 'Collins-Sussman, Ben',
      'cover' => nil,
      'masthead' => nil
    }
  end

  def extract_sections
    @base_url = 'http://svnbook.red-bean.com/en/1.7/'
    url = 'http://svnbook.red-bean.com/en/1.7/index.html'
    html = run_shell_command "curl -s #{url}"
    doc = Nokogiri::HTML html
    xs = []  # the sections
    frontmatter_section = {
      title: 'Frontmatter',
      articles: [ { title: 'Title Page', path: titlepage(doc) } ]
    }
    xs << frontmatter_section
    doc.search('.toc a').select {|a| a['href'] =~ /html$/}.each {|a|

      if a[:href] =~ /svn\.[a-z]+\.html/ 
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
    content = doc.at('.titlepage').inner_html 
    File.open("#{output_dir}/#{path}", 'w'){|f| f.puts content}
    path
  end


  def save_article filename
    path = "articles/#{filename}"
    return path if File.size?("#{output_dir}/#{path}")
    url = @base_url + filename
    html = run_shell_command("curl -s #{url}")
    doc = Nokogiri::HTML html

    doc.search("script").map &:remove
    doc.search(".navfooter").map &:remove
    doc.search(".navheader").map &:remove
    doc.search("#vcws-footer").map &:remove
    doc.search("#vcws-version-notice").map &:remove
    doc.search(".toc").map &:remove
    # images have relative paths, so fix them
    doc.search("img[@src]").each {|img|
      if img['src'] !~ %r{^http}
        img['src'] = @base_url + img['src']
      end
    }

    content = doc.at('body').inner_html
    File.open("#{output_dir}/#{path}", 'w'){|f| f.puts content}
    path
  end
end

SVN.generate
