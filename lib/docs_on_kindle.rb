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

  def run cmd
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
        run "curl -Ls '#{src}' > images/#{img_file}"
      end
      grayscale_image_path = "grayscale_images/#{img_file.gsub(/(\.\w+)$/, "-grayscale.gif")}"
      unless File.size?(grayscale_image_path)
        run "convert images/#{img_file}[0] -type Grayscale -depth 8 -resize '400x300>' #{grayscale_image_path}"
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
      xs = li.search("p").map {|p|
        # remove surrounding paragraph tags
        p.children.each {|c|
          li.add_child c
        }
        p.remove
      }.flatten

    }

  end

  def mobi!
    File.open("_document.yml", 'w'){|f| f.puts document.to_yaml}
    exec 'kindlerb'
  end
end
