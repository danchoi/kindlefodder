require 'kindlefodder'


class TraderJoes < Kindlefodder

  def get_source_files

    @start_url = "http://www.traderjoes.com/fearless-flyer"
    #@start_doc = Nokogiri::HTML run_shell_command("curl -s #{@start_url}")
    @start_doc = Nokogiri::HTML File.read("temp.html")

    sections = extract_sections

    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }

  end

   def download_cover_image
    if !File.size?("cover.gif")
      `curl -s 'http://www.traderjoes.com/images/fearless-flyer/logo-fearless-flyer.png' > cover.png`
      run_shell_command "convert cover.png -type Grayscale -resize '400x300>' cover.gif"
    end

   end

   def document 

    #download_cover_image

    {
      'title' => "Trader Joe's Fearless Flyer",
      'author' => "Trader Joe's",
      'cover' => 'cover.gif',
      'masthead' => nil,
    }
  end

 
  def extract_sections
    @start_doc.search('ul#category-list > li').
      select {|x| x.at("h3.category-title").inner_text == 'Beverages' }.
      map {|x|
      #puts x
      title = x.at("h3.category-title").inner_text
      $stderr.puts title
      
      articles_list = x.search("li a").map {|a| 
        path,description = save_article_and_return_path(a[:href])
        {
          title: a.inner_text,
          path: path,
          description: description,
          author: "Trader Joe's"

        }
      }
      puts articles_list.inspect
      { 
        title: title,
        articles: articles_list
      }
    }.compact
  end
 
  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')

    full_url = @start_url + '/' + href.sub(/^\//, '')

    html = run_shell_command "curl -s #{full_url}"
    article_doc = Nokogiri::HTML html
    article_doc = article_doc.at(".post")

    # article_doc = Nokogiri::HTML File.read("#{output_dir}/#{path}")
    

    # images have relative paths, so fix them
    article_doc.search("h2.title").each {|h2|
      h2.swap "<h3>#{h2.inner_text}</h3>"

    }
    article_doc.search("img[@src]").each {|img|
      if img['src'] =~ %r{^/}
        img['src'] = "http://www.traderjoes.com" + img['src']
        img['class'] = 'float-left'
      end
      if (p = img.parent.parent.parent) && p.name == 'p'
        puts "unnesting image: #{img['src']}"
        p.swap img
      end

    }

    description = article_doc.at("p").inner_text.strip.split(/\s+/)[0, 10].join(' ')

    res = article_doc.inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return [path, description]
  end
end

#TraderJoes.noclobber = true
TraderJoes.generate
