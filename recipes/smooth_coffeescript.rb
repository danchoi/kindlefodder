# coding: utf-8

require 'kindlefodder'
require 'pp'


class SmoothCoffeeScript < Kindlefodder
  
  def get_source_files
    @start_url = "http://autotelicum.github.com/Smooth-CoffeeScript/SmoothCoffeeScript.html"
    @start_doc = Nokogiri::HTML(run_shell_command("curl -s #{@start_url}"),nil,'UTF-8')

    sections = extract_sections
    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end
  
  def document 
    # download cover image
    if !File.size?("cover.gif")
      `curl -s 'http://autotelicum.github.com/Smooth-CoffeeScript/img/SmoothCoverWithSolutions.jpg' > cover.jpg`
      run_shell_command "convert cover.jpg -type Grayscale -resize '400x300>' cover.gif"
    end
    {
      'title' => 'Smooth CoffeeScript',
      'author' => 'E. Hoigaard',
      'cover' => 'cover.gif',
      'masthead' => nil
    }
  end
  
  def extract_sections
    
    
    
    articles = @start_doc.xpath("//h1|//div[@class='Addchap']").collect do |header|
      save_article_and_return_path header
    end .reject{|x| x.nil?} 
    
    reference_susections = @start_doc.xpath("//h3[@class='Subsection-']").collect do |header|
      save_article_and_return_path header
    end .reject{|x| x.nil?} 
    
    
    @toc_to_link_map = map_toc_to_link articles
    @toc_to_link_map = @toc_to_link_map.merge (map_toc_to_link reference_susections)
    
    PP.pp(@toc_to_link_map)

    def get_path_for_toc_link link
      raw_link = link.match(/^#(.*)/)[1]
      if @toc_to_link_map.has_key? raw_link
        "articles/"+to_fs_name(@toc_to_link_map[raw_link]) +".html"
      else
        "articles/"+to_fs_name(raw_link)+".html"
      end
    end
    
    sections = @start_doc.search('.toc').map do |sec_titl|
      sec_titl_a = sec_titl.at('a')
      if sec_titl_a and sec_titl_a[:href].match(/^#toc-(Part|Section)/i)
        title = sec_titl_a.inner_text
        sec = sec_titl.next_element
        articles_list = sec.search(".toc a").map {|a| 
           {
             path: get_path_for_toc_link(a[:href]),
             title: a.inner_text
           }
        }

        { 
          title: title,
          articles: articles_list
        }
        
      end
    end.reject {|section| 
      section.nil? or section[:title]=="Part V: Reference and Index" }
    
    sections[0][:articles].unshift ({
          title:"Foreword",
          path:"articles/chap.Foreword.html"
          })
    
    
    sections
  end
    
  def map_toc_to_link articles 
    m = {}
    articles.each do |article|
      if article.has_key? "link"
        m[article["toc_link"]] = article["link"]
      end
    end
    m
  end
    
  def to_fs_name link
    link.sub("/",".").sub(":",".")
  end

  def save_article_and_return_path header
    toc_link = header.at("a.toc")
    link = header.at("a.Label") 
    if link.nil? and toc_link.nil?
      return
    end

    

    if !toc_link.nil?
      toc_link_name = toc_link[:name]
      path = "articles/"+to_fs_name(toc_link_name) +".html"
    end
    if !link.nil?
      link_name = link[:name]
      path = "articles/" + to_fs_name(link_name) +".html"
    end

    current_element = header
    res = ""
    begin
      if current_element.inner_html.include? "○•○"
        current_element = current_element.next_element
      end
      
      res += current_element.to_html
      current_element = current_element.next_element
    end while current_element and current_element.name!="h1" and current_element.name!="h3"
    
    article_doc = Nokogiri::HTML res
    
    puts "Saving #{path}"
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts preprocess_article_doc(article_doc)}
    result = { 
      title:header.text,
      path:path,
      "toc_link"=>toc_link_name
      
    }
    if !link.nil?
      result["link"] = link_name
    end
    result
  end
  
  def preprocess_article_doc article_doc
    article_doc.xpath("//img").each do |img| 
      new_img_src = "http://autotelicum.github.com/Smooth-CoffeeScript/"+img[:src]
      puts "# IMG #{img[:src]} -> #{new_img_src}"
      img[:src] = new_img_src
    end
    
    article_doc.xpath("//a").each do |a|
      match = a[:href].match(/^#(.*)/) if a[:href]
      matched_href = ("book.html#"+ to_fs_name(match[1])) if match
      if !matched_href.nil?
        puts "# LINK #{a[:href]} -> #{matched_href}"
        a[:href] = matched_href
      end
    end
    article_doc.xpath("//pre").each do |pre|
      if pre.text.lines.count <2 and pre.text.length<40
        pre.name = "b"
        pre.parent.replace(pre)
      end
    end
    
    
    
    
    article_doc.to_html(encoding:'UTF-8')
  end
  
end

SmoothCoffeeScript.generate

