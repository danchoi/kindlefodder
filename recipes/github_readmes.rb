# Instructions: Pass this script a list of GitHub README urls either as
# arguments or as a list to STDIN

require 'kindlefodder'

class GithubReadmes < Kindlefodder

  def get_source_files
    @urls = STDIN.tty? ? ARGV : STDIN.readlines
    puts @urls.inspect
    sections = extract_sections
    puts sections.inspect
    File.open("#{output_dir}/sections.yml", 'w') {|f| f.puts sections.to_yaml }
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
    articles_list = @urls.map { |url|
      doc = Nokogiri::HTML run_shell_command("curl -s #{url}")
      title = doc.at('title').inner_text.sub(/ - GitHub$/,'') 
      $stderr.puts title
      readme = doc.at('#readme')
      articles_list = readme.search("h1",'h2').map {|h2|
        {title: h2.inner_text,
         path: save_article_and_return_path(h2)}
      }
      { 
        title: title,
        articles: articles_list
      }
    }
  end
 
  def save_article_and_return_path h2
    path = "articles/" + h2.inner_text.gsub(/\W/, '-')
    nodes = h2.xpath("./following-sibling::*").take_while {|x| x.name != 'h2'}
    content = nodes.map(&:to_html).join("\n")
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts content}
    path
  end
end

GithubReadmes.generate
