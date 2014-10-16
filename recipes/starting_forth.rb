require 'kindlefodder'

class StartingForth < Kindlefodder
  
  def get_source_files
    # fetch first page (with TOC)
    @base_url = "http://home.vianetworks.nl/users/mhx/"
    @start_url = "#{@base_url}sf.html"
    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{@start_url}")

    # create sections.yml
    sections = [{
      title:"Main",
      articles:extract_articles
      }]
    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end
  
  def document 
    # download cover image
    if !File.size?("cover.gif")
      `curl -s 'http://home.iae.nl/users/mhx/sf%20front.jpg' > cover.jpg`
      run_shell_command "convert cover.jpg -type Grayscale -resize '400x300>' cover.gif"
    end
    # book's info
    {
      'title' => 'Starting Forth',
      'author' => 'Leo Brodie',
      'cover' => 'cover.gif',
      'masthead' => nil
    }
  end
  

  def extract_articles
    # iterating over Table of Contents and extracting articles
    @start_doc.search('a').map do |o|
      if o[:href].match(/^sf/i)

        title = o.inner_text

        FileUtils::mkdir_p "#{output_dir}/articles"

        {
          title: title,
          path: save_article_and_return_path(o[:href])
        }
      end
    end.reject {|article| 
      article.nil?}
  end
  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    # fetching article
    full_url = @base_url + href.sub(/^\//, '')
    base_article_url = File.dirname(full_url)+"/"
    html = run_shell_command "curl -s #{full_url}"
    # cleaning article
    article_doc = Nokogiri::HTML html
    article_doc.xpath("//a[@href='http://validator.w3.org']").each do |a|
      a.remove()
    end
    article_doc.xpath("//img").each do |img| 
      new_img_src = base_article_url+img[:src]
      puts "# IMG #{img[:src]} -> #{new_img_src}"
      img[:src] = new_img_src
    end
    article_doc.xpath("//a").each do |a|
      match = a[:href].match(/^( )?http/) if a[:href]
      if !match
        new_href = base_article_url+a[:href]
        puts "# LINK #{a[:href]} -> #{new_href}"
        a[:href] = new_href
      end
    end


    # saving article
    res = article_doc.inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    path
  end
end

StartingForth.generate

