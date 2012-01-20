#!/usr/bin/env ruby

require 'docs_on_kindle'

class HerokuDocs
  include ::DocsOnKindle 

  OUTPUT_DIR = "src/heroku"
  `mkdir -p #{OUTPUT_DIR}`

  def get_source_files
    start_url = "http://devcenter.heroku.com/categories/add-on-documentation" 
    @start_doc = Nokogiri::HTML `curl -s #{start_url}`
    File.open("#{OUTPUT_DIR}/sections.yml", 'w') {|f|f.puts extract_sections.to_yaml}
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

  def build_kindlerb_tree
    sections = YAML::load_file "#{OUTPUT_DIR}/sections.yml"
    sections.select! {|s| !s[:articles].empty?}
    Dir.chdir OUTPUT_DIR do
      sections.each_with_index {|s, section_idx|
        title = s[:title]
        FileUtils::mkdir_p("sections/%03d" % section_idx)
        File.open("sections/%03d/_section.txt" % section_idx, 'w') {|f| f.puts title}
        puts "sections/%03d -> #{title}" % section_idx
        # save articles
        s[:articles].each_with_index {|a, item_idx|
          article_title = a[:title]
          /(?<path>articles\/[\w-]+)(#\w+|)$/ =~ a[:url]
          puts a[:url], path
          item = Nokogiri::HTML(File.read path)

          download_images! item
          fixup_html! item

          item_path = "sections/%03d/%03d.html" % [section_idx, item_idx] 
          add_head_section item, article_title
          # fix all image links
          # item.search("img").each { |img|
            #img['src'] = "#{Dir.pwd}/#{img['src']}"
          #}
          File.open(item_path, 'w'){|f| f.puts item.to_html}
          puts "  #{item_path} -> #{article_title}"
        }
      }
      mobi!
    end
  end

  def extract_sections
    @start_doc.search('select[@id=quicknav] option').map {|o| 
      title = o.inner_text
      $stderr.puts "#{title}"
      s = { 
        title: title,
        articles: articles(`curl -s http://devcenter.heroku.com#{o[:value]}`) 
      }
    }
  end
  
  def articles html
    category_page = Nokogiri::HTML html 
    xs = category_page.search("ul.articles a").map {|x|
      title = x.inner_text.strip
      href = x[:href] =~ /^http/ ? x[:href] : "http://devcenter.heroku.com#{x[:href]}" 
      $stderr.puts "-  #{title}"
      a = { 
        title: title,
        url: href
      }
    }
  end

  def article href
    /(?<filename>[\w-]+)$/ =~ href
    a = Nokogiri::HTML `curl -s #{href}`    
    FileUtils::mkdir_p "#{OUTPUT_DIR}/articles"
    path = "#{OUTPUT_DIR}/articles/#{filename}"
    File.open(path, 'w') {|f| f.puts(a.at('article').inner_html)}
  end
end


HerokuDocs.new.get_source_files
HerokuDocs.new.build_kindlerb_tree
