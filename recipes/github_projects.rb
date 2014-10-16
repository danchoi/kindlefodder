# encoding: utf-8

# Instructions: 
# The README pages for this recipe are scraped from
# https://github.com/danchoi/kindlefodder/wiki/Github-READMEs-and-pages-for-the-GitHub-project-docs-recipe
# You can edit that wiki page, add more popular repositories that you would like to scrape
# and generate into a mobi format

require 'kindlefodder'

class GithubProjects < Kindlefodder
  WIKIPAGE = 'https://github.com/danchoi/kindlefodder/wiki/Github-READMEs-for-the-github_projects.rb-recipe'

  def get_source_files
    @urls = Nokogiri::HTML(`curl -Ls "#{WIKIPAGE}"`).
      search("#wiki-body h2").
      inject({}) do |m, h2|
        m[h2.inner_text] = h2.xpath("./following-sibling::ul[1]/li").map { |li| li.inner_text }
        m
    end
    puts @urls.to_yaml
    sections = extract_sections
    puts sections.inspect
    File.open("#{output_dir}/sections.yml", 'w') {|f| f.puts sections.to_yaml }
  end

  def document
    {
      'title' => 'GitHub Projects',
      'author' => 'Various',
      'cover' => nil,
      'masthead' => nil,
    }
  end
 
  def extract_sections
    @urls.map do |(title, urls)|
      {
        title: title,
        articles: urls.map do |url|
          html = run_shell_command("curl -s #{url}")
          html = html.force_encoding(Encoding::UTF_8)
          doc = Nokogiri::HTML(html)
          title = doc.at('title').inner_text.match(/([^ ]+)/)[0]
          $stderr.puts title
          readme = doc.at('#readme') || doc.at('#wiki-wrapper')
          {
            title: title,
            path: save_article_and_return_path(readme, title)
          }
        end
      }
    end
  end

  def fixup_html!(doc)
    # stub this out because it causes encoding issues with UTF characters like em-dash
    # (investigate this later)
  end
 
  def save_article_and_return_path readme, title
    path = "articles/#{title.gsub(/\W/, '-')}"
    content = readme.inner_html
    File.open("#{output_dir}/#{path}", 'w') { |f| f.puts(content) }
    path
  end
end

GithubProjects.generate
