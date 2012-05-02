# encoding: utf-8 
=begin

Require this file in your recipe and subclass KindleFodder.

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

class Kindlefodder

  STYLESHEET = File.absolute_path "css/kindle.css"

  class << self
    attr_accessor :noclobber, :nomobi
  end

  # Run the recipe class with this command

  def self.generate
    puts "output dir is #{output_dir}"
    if self.noclobber
      puts "Preserving files in #{output_dir}"
    else
      run_shell_command "rm -rf #{output_dir}"
    end
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
        File.open("sections/%03d/_section.txt" % section_idx, 'w:utf-8') {|f| f.puts title}
        puts "sections/%03d -> #{title}" % section_idx
        # save articles
        s[:articles].each_with_index {|a, item_idx|
          article_title = a[:title]
          path = a[:path]
          puts a[:url], path
          puts "Processing '#{a[:title]}' on path: #{path}"
          item = Nokogiri::HTML(File.open(path,'r:utf-8').read, nil, 'UTF-8')
          download_images! item
          fixup_html! item
          item_path = "sections/%03d/%03d.html" % [section_idx, item_idx] 
          description = a[:description]
          author = a[:author]
          add_head_section item, article_title, description, author
          out = item.to_html

          File.open(item_path, 'w:utf-8'){|f| f.puts out}
          puts "  #{item_path} -> #{article_title}"
          exit
        }
      }
      mobi! unless self.class.nomobi
    end
  end

  def add_head_section(doc, title, description='', author='')
    head = Nokogiri::XML::Node.new "head", doc
    title_node = Nokogiri::XML::Node.new "title", doc
    title_node.content = title
    title_node.parent = head
    description_node = Nokogiri::XML::Node.new "meta", doc
    description_node['name'] = 'description'
    description_node['content'] = description
    description_node.parent = head
    author_node = Nokogiri::XML::Node.new "meta", doc
    author_node['name'] = 'author'
    author_node['content'] = author
    author_node.parent = head
    css = Nokogiri::XML::Node.new "link", doc
    css['rel'] = 'stylesheet'
    css['type'] = 'text/css'
    css['href'] = STYLESHEET
    css.parent = head
    doc.at("body").before head
  end

  def self.run_shell_command cmd
    puts "  #{cmd}"
    `#{cmd}`
  end

  def run_shell_command cmd
    self.class.run_shell_command cmd
  end

  def download_images! doc
    doc.search('img').each {|img|
      src = img[:src] 
      /(?<img_file>[^\/]+)$/ =~ src

      FileUtils::mkdir_p 'images'
      FileUtils::mkdir_p 'processed_images'
      unless File.size?("images/#{img_file}")
        run_shell_command "curl -Ls '#{src}' > images/#{img_file}"
        if img_file !~ /(png|jpeg|jpg|gif)$/i
          filetype = `identify images/#{img_file} | awk '{print $2}'`.chomp.downcase
          run_shell_command "mv images/#{img_file} images/#{img_file}.#{filetype}"
          img_file = "#{img_file}.#{filetype}"
        end
      end
      processed_image_path = "processed_images/#{img_file.gsub('%20', '_').sub(/(\.\w+)$/, "-grayscale.gif")}"
      sleep 0.1
      unless File.size?(processed_image_path)
        run_shell_command "convert images/#{img_file} -compose over -background white -flatten -resize '300x200>' -alpha off #{processed_image_path}"
      end
      img['src'] = [Dir.pwd, processed_image_path].join("/")
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
        p.swap p.children
        p.remove
      }
      # remove any leading spaces before elements inside any li tag
      # THIS causes encoding problems!
      #li.inner_html = li.inner_html.strip
      if (n = li.children.first).text?
        n.content = n.content.strip
      end
    }
  end

  # some fixup utitity methods

  def tighten_pre doc
    # remove trailing and leading padding from <pre> sections
    doc.search('pre').each {|x|
      x.inner_html = x.inner_html.strip
    }
  end

  # name is usually "li,dd"
  def tighten_lists doc, target="li,dd"
    doc.search(target).each {|x|
      x.search('p').each {|p| 
        p.swap p.children
        p.remove
      }
      x.inner_html = x.inner_html.strip
    }
  end



  def default_metadata
    {
      'doc_uuid' => "#{self.class.recipe_slug}-documentation-#{Date.today.to_s}",
      'title' => "#{self.class.to_s} Documentation",
      'author' => self.class.to_s,
      'publisher' => 'github.com/danchoi/kindlefodder', 
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
