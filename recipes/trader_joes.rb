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
      # select {|x| x.at("h3.category-title").inner_text =~ /Wine/ }.
      map {|x|
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
    if $use_cached_html
      article_doc = Nokogiri::HTML File.read("#{output_dir}/#{path}")
    else
      html = run_shell_command "curl -s #{full_url}"
      article_doc = Nokogiri::HTML html
      article_doc = article_doc.at(".post")
    end

    # images have relative paths, so fix them
    article_doc.search("h2.title").each {|h2|
      h2.name = 'h3'
    }
    article_doc.search("span").each {|span|
      span.remove_attribute 'style'
    }
    article_doc.search("img[@src]").each {|img|
      if img['src'] =~ %r{^/}
        img['src'] = "http://www.traderjoes.com" + img['src']
      end
      img.remove_attribute('style')
      img['class'] = "float-left"
      p = img.ancestors.detect {|n| n.name == 'p'}
      if p 
        p.before img
      end
    }

    description = ((p = article_doc.at("p")) && p.inner_text.strip.split(/\s+/)[0, 10].join(' ')) || ''

    res = article_doc.inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return [path, description]
  end
end

#$use_cached_html = true
if $use_cached_html
  TraderJoes.noclobber = true
end
TraderJoes.generate
