#!/usr/bin/env ruby
require 'docs_on_kindle'

class Heroku < DocsOnKindle 

  def get_source_files
    start_url = "http://devcenter.heroku.com/categories/add-on-documentation" 
    @start_doc = Nokogiri::HTML `curl -s #{start_url}`
    File.open("#{output_dir}/sections.yml", 'w') {|f|f.puts extract_sections.to_yaml}
  end

  def document 
    {
      'doc_uuid' => "heroku-docs-#{Date.today.to_s}",
      'title' => "Heroku Documentation",
      'publisher' => "Heroku",
      'author' => "Heroku",
      'subject' => 'Reference',
      'date' => Date.today.to_s,
      'cover' => nil,
      'masthead' => nil,
      'mobi_outfile' => "heroku-guide.#{Date.today.to_s}.mobi"
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
    File.open(path, 'w') {|f| f.puts(article_doc.at('article').inner_html)}
  end
end

Heroku.generate
