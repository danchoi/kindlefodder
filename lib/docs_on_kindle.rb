=begin

Require this file and include this module into each recipe.

Your recipe class is responsible for getting all the source HTML necessary to
build the ebook.

See recipes/heroku.rb for an example.

=end

unless `which convert` =~ /convert/
  abort "You need to install imagemagick"
end

require 'nokogiri'
require 'fileutils'
require 'yaml'
require 'date'

class DocsOnKindle

  STYLESHEET = File.absolute_path "css/kindle.css"


  # Run the recipe class with this command

  def self.generate
    puts "output dir is #{output_dir}"
    `rm -rf #{output_dir}`
    `mkdir -p #{output_dir}/articles`
    generator = new
    generator.get_source_files
    generator.build_kindlerb_tree
  end

  def self.recipe_slug
    self.to_s.gsub(/([a-z]+)([A-Z][a-z]+)/, '\1_\2').downcase  
  end

  def self.output_dir
    d = "src/#{recipe_slug}"
    FileUtils::mkdir_p d
    d
  end

  def output_dir
    self.class.output_dir
  end

  def build_kindlerb_tree
    sections = YAML::load_file "#{output_dir}/sections.yml"
    sections.select! {|s| !s[:articles].empty?}
    Dir.chdir output_dir do
      sections.each_with_index {|s, section_idx|
        title = s[:title]
        FileUtils::mkdir_p("sections/%03d" % section_idx)
        File.open("sections/%03d/_section.txt" % section_idx, 'w') {|f| f.puts title}
        puts "sections/%03d -> #{title}" % section_idx
        # save articles
        s[:articles].each_with_index {|a, item_idx|
          article_title = a[:title]
          path = a[:path]
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
      grayscale_image_path = "grayscale_images/#{img_file.gsub('%20', '_').sub(/(\.\w+)$/, "-grayscale.gif")}"
      sleep 0.1
      unless File.size?(grayscale_image_path)
        run_shell_command "convert images/#{img_file} -compose over -background white -flatten -type Grayscale -resize '400x300>' -alpha off #{grayscale_image_path}"
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
=begin
      # remove any leading spaces after elements inside any li tag

      NOTE: this is too broad. Do on a per recipe basis

      li.xpath('.//*').each {|x| 
        c = x.children[0]
        if c && c.text? && c.content.strip == ''
          puts "  Removing empty text node first child within <li>"
          c.remove
        end
      } 
=end
    }
  end

  def default_metadata
    {
      'doc_uuid' => "#{self.class.recipe_slug}-documentation-#{Date.today.to_s}",
      'title' => "#{self.class.to_s} Documentation",
      'author' => self.class.to_s,
      'publisher' => 'github.com/danchoi/docs_on_kindle', 
      'subject' => 'Reference', 
      'date' => Date.today.to_s,
      'mobi_outfile' => "#{self.class.recipe_slug}.#{Date.today.to_s}.mobi"
    }
  end

  def mobi!
    File.open("_document.yml", 'w') {|f| 
      d = default_metadata.merge(document)
      f.puts d.to_yaml
    }
    exec 'kindlerb'
  end
end
