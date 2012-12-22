require 'kindlefodder'

class LittleCoffeeScript < Kindlefodder
  
  def get_source_files
    # fetch first page (with TOC)
    @start_url = "http://arcturo.github.com/library/coffeescript/"
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
      `curl -s 'http://akamaicovers.oreilly.com/images/0636920024309/lrg.jpg' > cover.jpg`
      run_shell_command "convert cover.jpg -type Grayscale -resize '400x300>' cover.gif"
    end
    # book's info
    {
      'title' => 'The Little Book on CoffeeScript',
      'author' => 'Alex MacCaw',
      'cover' => 'cover.gif',
      'masthead' => nil
    }
  end
  

  def extract_articles
    # iterating over Table of Contents and extracting articles
    @start_doc.search('ol.pages li a').map do |o|
      title = o.inner_text

      FileUtils::mkdir_p "#{output_dir}/articles"

      {
        title: title,
        path: save_article_and_return_path(o[:href])
      }
    end
  end
  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    # fetching article
    full_url = @start_url + href.sub(/^\//, '')
    html = run_shell_command "curl -s #{full_url}"
    # cleaning article
    article_doc = Nokogiri::HTML html
    b = article_doc.at(".back")
    b.remove if b
    # saving article
    res = article_doc.at('#content').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    path
  end
end

LittleCoffeeScript.generate

