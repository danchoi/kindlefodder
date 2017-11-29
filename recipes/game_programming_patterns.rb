require 'kindlefodder'

class GameProgrammingPatterns < Kindlefodder

  URL = 'http://gameprogrammingpatterns.com'

  def get_source_files
    start_url = "#{URL}/contents.html"

    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{start_url}")

    File.open("#{output_dir}/sections.yml", 'w') { |f|
      f.puts extract_sections.to_yaml
    }
  end

  def document
    if !File.size?("cover.gif")
      `curl -s 'https://images-na.ssl-images-amazon.com/images/I/71Kfg2zTisL.jpg' > cover.jpg`
      run_shell_command "convert cover.jpg -type Grayscale -resize '400x300>' cover.gif"
    end
    {
      'title' => 'Game Programming Patterns',
      'author' => 'Bob Nystrom',
      'cover' => 'cover.gif',
      'masthead' => nil,
    }
  end

  def extract_sections
    @start_doc.xpath('//div[@class="content"]/ol/li').map { |li|
      title = li.at("strong").inner_text
      $stderr.puts title
      articles_list = li.search("a").map { |a|
        {
          title: a.inner_text,
          path: save_article_and_return_path(a[:href])
        }
      }

      {
        title: title,
        articles: articles_list
      }
    }.compact
  end

  def save_article_and_return_path href
    path = "articles/#{href}"
    article_doc = Nokogiri::HTML run_shell_command "curl -s #{URL}/#{href}"

    # remove nav
    article_doc.search("nav").each &:remove

    # images have relative paths, so fix them
    article_doc.search("img[@src]").each { |img|
      img['src'] = "#{URL}/#{img['src']}"
    }

    res = article_doc.at('div.content').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return path
  end

end

GameProgrammingPatterns.generate
