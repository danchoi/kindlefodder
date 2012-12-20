require 'kindlefodder'

class LittleCoffeeScript < Kindlefodder
  
  def get_source_files
    @start_url = "http://arcturo.github.com/library/coffeescript/"
    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{@start_url}")

    sections = extract_articles

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
    {
      'title' => 'The Little Book on CoffeeScript',
      'author' => 'Alex MacCaw',
      'cover' => 'cover.gif',
      'masthead' => nil
    }
  end
  

  def extract_articles
    @start_doc.search('ol.pages li a').map do |o|
      puts o
      title = o.inner_text

      $stderr.puts "#{title}"

      FileUtils::mkdir_p "#{output_dir}/articles"

      {
        title: title,
        path: save_article_and_return_path(o[:href])
      }
    end
  end
  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    full_url = @start_url + href.sub(/^\//, '')
    puts path, full_url
    html = run_shell_command "curl -s #{full_url}"
    article_doc = Nokogiri::HTML html
    b = article_doc.at(".back")
    b.remove if b
    res = article_doc.at('#content').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    path
  end
  
end

LittleCoffeeScript.generate

