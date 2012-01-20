require 'docs_on_kindle'


class ThoughtbotPlaybook < DocsOnKindle

  def get_source_files
    @start_url = "http://playbook.thoughtbot.com/"
    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{@start_url}")

    sections = extract_sections

    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
  end

   def document 
    {
      'title' => 'thoughtbot playbook',
      'author' => 'thoughtbot',
      'cover' => nil,
      'masthead' => nil,
    }
  end

 
  def extract_sections
    [{ 
      title: "Frontmatter", 
      articles: [ { title: "Hello, we're thoughtbot", path: save_article_and_return_path('', 'hello') } ]
    }] + 
    @start_doc.search('li.nav h2').map {|h2|
      a = h2.at("a")
      title = a.inner_text
      $stderr.puts title

      ul = h2.xpath("./following-sibling::*").detect {|x| x.name == "ul"}

      articles_list = ul.search("li a").map {|a| 
        {
          title: a.inner_text,
          path: save_article_and_return_path(a[:href])
        }
      }

      { 
        title: title,
        articles: articles_list
      }
    }
  end
 
  def save_article_and_return_path href, filename=nil
    path = filename || "articles/" + href.sub(/^\//, '').sub(/\/$/, '').gsub('/', '.')
    full_url = @start_url + href.sub(/^\//, '')

    html = run_shell_command "curl -s #{full_url}"

    article_doc = Nokogiri::HTML html
    b = article_doc.at(".breadcrumbs")
    b.remove if b
    res = article_doc.at('section').inner_html

    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts res}
    return path
  end
end

ThoughtbotPlaybook.generate
