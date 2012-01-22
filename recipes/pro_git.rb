require 'kindlefodder'


class ProGit < Kindlefodder

  def get_source_files

    @start_url = "http://progit.org/book/"
    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{@start_url}")

    sections = extract_sections

    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }

  end

   def document 
    # download cover image
    if !File.size?("cover.gif")
      `curl -s 'http://progit.org/images/book-big.jpg' > cover.jpg`
      run_shell_command "convert cover.jpg -type Grayscale -resize '400x300>' cover.gif"
    end
    {
      'title' => 'Pro Git',
      'author' => 'Scott Chacon',
      'cover' => 'cover.gif',
      'masthead' => nil,
    }
  end

 
  def extract_sections
    [{ 
      title: "Frontmatter", 
      articles: [ { title: "About", path: save_article_and_return_path('/about.html') } ]
    }] + 
    @start_doc.search('#toc h1').map {|h1|
      a = h1.at("a")
      title = a.inner_text
      next if title == 'Index of Commands' # skip this section
      $stderr.puts title
      ul = h1.parent.xpath("./following-sibling::*").detect {|x| x.name == "ul"}
      articles_list = ul.search("li a").map {|a| 
        {
          title: a.inner_text,
          path: save_article_and_return_path(a[:href])
        }
      }

      articles_list.unshift({
        title: title, # section title
        path: save_article_and_return_path(a[:href]) # section href
      })

      { 
        title: title,
        articles: articles_list
      }
    }.compact
  end
 
  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    full_url = if href =~ %r{^/}
      @start_url.sub('/book/', '') + href
    else
      @start_url + href.sub(/^\//, '')
    end

    html = run_shell_command "curl -s #{full_url}"

    article_doc = Nokogiri::HTML html

    # remove prev/next nav
    nav = article_doc.at("#nav")
    nav.remove if nav

    # images have relative paths, so fix them
    article_doc.search("img[@src]").each {|img|
      if img['src'] =~ %r{^/}
        img['src'] = "http://progit.org" + img['src']
      end
    }

    res = article_doc.at('#content').inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return path
  end
end

ProGit.generate
