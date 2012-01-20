=begin

Require this file and include this module into each recipe.

Your recipe class is responsible for getting all the source HTML necessary to
build the ebook.

=end

require 'fileutils'
require 'nokogiri'
require 'fileutils'
require 'yaml'
require 'date'

module DocsOnKindle

  STYLESHEET = File.absolute_path "css/kindle.css"

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

          File.open(item_path, 'w'){|f| f.puts item.to_html}
          puts "  #{item_path} -> #{article_title}"
        }
      }
      mobi!
    end
  end


  def add_head_section(doc, title)
    head = Nokogiri::XML::Node.new "head", doc
    title_node = Nokogiri::XML::Node.new "title", doc
    title_node.content = title
    title_node.parent = head
    css = Nokogiri::XML::Node.new "link", doc
    css['rel'] = 'stylesheet'
    css['type'] = 'text/css'
    css['href'] = STYLESHEET
    css.parent = head
    doc.at("body").before head
  end

  def run_shell_command cmd
    puts "  #{cmd}"
    `#{cmd}`
  end

  def download_images! doc
    doc.search('img').each {|img|
      src = img[:src] 
      /(?<img_file>[^\/]+)$/ =~ src
      FileUtils::mkdir_p 'images'
      FileUtils::mkdir_p 'grayscale_images'
      unless File.size?("images/#{img_file}")
        run_shell_command "curl -Ls '#{src}' > images/#{img_file}"
      end
      grayscale_image_path = "grayscale_images/#{img_file.gsub(/(\.\w+)$/, "-grayscale.gif")}"
      unless File.size?(grayscale_image_path)
        run_shell_command "convert images/#{img_file}[0] -type Grayscale -depth 8 -resize '400x300>' #{grayscale_image_path}"
      end
      img['src'] = [Dir.pwd, grayscale_image_path].join("/")
    }
  end
  
  def fixup_html! doc

    # Sort of a hack to improve dt elements spacing
    # Using a css rule margin-top doesn't work
    doc.search('dt').each {|dt|
      dt.children.first.before(Nokogiri::XML::Node.new("br", doc))
    }

    # We want to remove nested 'p' tags in 'li' tags, because these introduce an undesirable 
    # blank line after the bullet. The expected CSS fix doesn't work.
    doc.search('li').each {|li|
      li.search("p").each {|p|
        # remove surrounding paragraph tags
        p.children.each {|c|
          li.add_child c
        }
        p.remove
      }
      # remove any spaces 

    }

  end

  def mobi!
    File.open("_document.yml", 'w'){|f| f.puts document.to_yaml}
    exec 'kindlerb'
  end
end
