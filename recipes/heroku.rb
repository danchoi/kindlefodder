#!/usr/bin/env ruby
require 'docs_on_kindle'

class Heroku < DocsOnKindle 

  def get_source_files

    # The start_url is any webpage that will contain the navigation structure
    # of the documentaion

    start_url = "http://devcenter.heroku.com/categories/add-on-documentation" 

    @start_doc = Nokogiri::HTML `curl -s #{start_url}`

    File.open("#{output_dir}/sections.yml", 'w') {|f|

      # extract_sections() is defined below.  It gets the sections of the ebook
      # out of the webpage docs navigation sidebar.

      f.puts extract_sections.to_yaml
    }
  end

  # This method is for the ebook metadata.

  def document 
    {
      # Fill these in with full paths if available
      # No sure yet what the proper dimensions are.

      'cover' => nil,
      'masthead' => nil,
    }
  end

  def extract_sections
    @start_doc.search('select[@id=quicknav] option').map {|o| 
      title = o.inner_text
      $stderr.puts "#{title}"
      s = { 
        title: title,
        articles: get_articles(`curl -s http://devcenter.heroku.com#{o[:value]}`) 
      }
    }
  end
  
  def get_articles html
    category_page = Nokogiri::HTML html 
    xs = category_page.search("ul.articles a").map {|x|
      title = x.inner_text.strip
      href = x[:href] =~ /^http/ ? x[:href] : "http://devcenter.heroku.com#{x[:href]}" 
      $stderr.puts "-  #{title}"
      save_article href
      a = { 
        title: title,
        url: href
      }
    }
  end

  def save_article href
    /(?<filename>[\w-]+)$/ =~ href
    article_doc = Nokogiri::HTML `curl -s #{href}`    
    FileUtils::mkdir_p "#{output_dir}/articles"
    path = "#{output_dir}/articles/#{filename}"

    # Save just the HTML fragment that contains the article text. Throw out everything else.

    File.open(path, 'w') {|f| f.puts(article_doc.at('article').inner_html)}
  end
end

Heroku.generate
