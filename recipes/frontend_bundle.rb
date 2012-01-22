=begin

HAML reference
http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html

SCSS reference
http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html

CoffeeScript reference
http://coffeescript.org/#comparisons

=end

require 'kindlefodder'

class FrontendBundle < Kindlefodder

  def get_source_files
    sections = extract_sections
    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end

  def document 
    {
      'title' => 'Haml/Sass/CoffeeScript',
      'author' => 'Open Source Community',
      'cover' => nil,
      'masthead' => nil
    }
  end

  def extract_sections
    [
      section_from_yard('http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html', 'Haml Reference'),
      section_from_yard('http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html', 'Sass Reference'),
      coffee_sections
    ]
  end
 
  # YARD refers to YARD generated documentation

  def section_from_yard(url, s_title)
    doc = Nokogiri::HTML `curl -Ls #{url}`
    {
      title: s_title,
      # extract just one level of nesting for articles
      articles: doc.xpath("//div[@class='maruku_toc']/ul/li/a").map {|a|
        title = a.inner_text
        href = a[:href]
        $stderr.puts("article: " + title)

        # extract article content

        h2 = doc.at(href)
        body = h2.xpath("./following-sibling::*").take_while {|n| n.name != 'h2'}
        content = h2.to_html + body.map(&:to_html).join("\n")
        # If this is the "Features" section, grab the preceding paragraph
        if title == 'Features'
          content = h2.xpath("./preceding-sibling::p").to_html + content
        end
        path = "#{s_title}.#{title.downcase.gsub(/\W/, '_')}"
        File.open("#{output_dir}/#{path}", 'w') {|f| f.puts content}

        {
          title: title,
          path: path
        }
      }.compact
    }
  end

  def coffee_sections
    url = 'http://coffeescript.org/'
    doc = Nokogiri::HTML `curl -Ls #{url}`

    # fix up the documentation. p and h2 are inconsistent.
    
    doc.search("span[@id]").select {|span| span.parent.name == 'p'}.each {|span|
      puts span.to_html
      b = span.xpath("./following-sibling::b")[0]
      t = b.inner_text
      puts "Fixing span tag: #{t}"
      h2 = Nokogiri::XML::Node.new "h2", doc
      h2.content = t
      span.parent.before(h2)
      b.remove
      span.parent = h2
    }
    doc.xpath("//*[@onclick]").each {|n| n.remove_attribute('onclick')}
    # strip all the span tags that are used for HTML syntax highlighting
    doc.search(".FunctionName,.Storage,.FunctionArgument,.Keyword,.String,.BuiltInConstant").each {|s| 
      q = Nokogiri::XML::Text.new( s.inner_text, doc )
      s.swap q
    }
    # strip run script controls
    doc.search(".minibutton").each &:remove

    # Strip whitespace at the end of <pre> bodies (due to coffeescript's
    # brevity compared to js.

    # Also, for each of <pre> sections, label the first coffeescript and the
    # second javascript, because we can't fit the two column code comparison of
    # the web version.
    doc.search("pre").each {|pre| 
      pre.inner_html = pre.inner_html.rstrip
      if (v = pre.xpath("./following-sibling::*")[0])  && v.name == 'pre'
        pre.before("<h3 style='text-align:right;font-style:italic'>CoffeeScript</h3>")
        pre.after("<h3 style='text-align:right;font-style:italic'>JavaScript</h3>")
      end
    }

    
    {
      title: "CoffeeScript Reference",
    
      articles: doc.search(".toc .menu a").map {|a|
        title = a.inner_text
        href = a[:href]
        $stderr.puts("article: " + title)

        # extract article content
        
        h2 = doc.at(href).parent
        body = h2.xpath("./following-sibling::*").take_while {|n| n.name != 'h2'}
        content = h2.to_html + body.map(&:to_html).join("\n")
        # If this is the "Overview" section, grab the preceding paragraph
        if title == 'Overview'
          content = h2.xpath("./preceding-sibling::p").map(&:to_html).join("\n") + content
        end

        # strip stuff out
        d = Nokogiri::HTML content
        d.search("script").map &:remove

        path = "coffee.#{title.downcase.gsub(/\W/, '_')}"
        File.open("#{output_dir}/#{path}", 'w') {|f| f.puts d.to_html}
        {
          title: title,
          path: path
        }
      }.compact
    }

  end



end

FrontendBundle.generate
exit

xs = FrontendBundle.new.extract_sections
puts xs.to_yaml
puts xs[0][:articles].size

