# encoding: utf-8

# Instructions: 
# The README pages for this recipe are scraped from https://github.com/danchoi/kindlefodder/wiki/Github-READMEs-and-pages-for-the-GitHub-project-docs-recipe
# You can edit that wiki page

require 'kindlefodder'

class GithubReadmes < Kindlefodder

  def get_source_files
    @sections = YAML::load_file File.join(File.dirname(__FILE__), 'github_readmes.yml')
    @sections.inspect
    sections = extract_sections
    puts sections.inspect
    File.open("#{output_dir}/sections.yml", 'w') {|f| f.puts sections.to_yaml }
  end

  def document
    {
      'title' => 'GitHub Readmes',
      'author' => 'Open Source',
      'cover' => nil,
      'masthead' => nil,
    }
  end
 
  def extract_sections
    sections = @sections.map { |(title, urls)|
      { title: title,
        articles: urls.map {|url|
          html = run_shell_command("curl -s #{url}")
          html = html.force_encoding('utf-8')
          doc = Nokogiri::HTML html
          title = doc.at('title').inner_text.sub(/ - GitHub$/,'') 
          $stderr.puts title
          readme = doc.at('#readme')
          { 
            title: title,
            path: save_article_and_return_path(readme, title)
          }
        }
      }
    }
  end

  def fixup_html! doc
    # stub this out because it causes encoding issues with UTF characters like em-dash
    # (investigate this later)
  end
 
  def save_article_and_return_path readme, title
    path = "articles/" + title.gsub(/\W/, '-')
    content = readme.inner_html
    File.open("#{output_dir}/#{path}", 'w') {|f| f.puts content}
    path
  end
end

GithubReadmes.generate
