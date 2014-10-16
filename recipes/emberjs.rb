
=begin

The internals of a recipe are up to you, but a recipe should do at least the
following:

First, require 'kindlefodder' and subclass Kindlefodder.

Second, contain a #get_source_files method that does two things:

1. Save a sections.yml to the path returned by the superclass's #output_dir
method with the following format:

---
- :title: Getting Started
  :articles:
  - :title: Getting Started with Heroku
    :path: articles/quickstart
- :title: Platform Basics
  :articles:
  - :title: Architecture Overview
    :path: articles/architecture-overview
  - :title: Dyno Isolation
    :path: articles/dyno-isolation
  [etc.]

2. Save HTML fragments of the article content at the path values (relative to
#output_dir) indicated in the sections.yml above

The recipe class should also contain a #document method that returns a metadata
hash as shown below. The masthead and cover values seem optional. But if you fill
them in, use paths relative to output_dir.

=end

require 'kindlefodder'
require 'pry'

class Emberjs < Kindlefodder
  def get_source_files
    # The start_url is any webpage that will contain the navigation structure
    # of the documentaion

    start_url = "http://emberjs.com/guides/"

    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{start_url}")

    File.open("#{output_dir}/sections.yml", 'w') do |f|
      f.puts extract_sections.to_yaml
    end
  end

  def document
    {
      'title' => 'EMBER.JS GUIDES',
      'cover' => nil,
      'masthead' => nil,
    }
  end

  def extract_sections
    chapters = @start_doc.search("li.level-1")
    chapters.map do |chapter|
      title = chapter.children[1].text
      $stderr.puts "#{title}"
      sub_topics = chapter.css("li.level-3")
      {
        title: title,
        articles: get_articles(sub_topics)
      }
    end
  end

  # For each section, this method saves the HTML fragment of each article's
  # content to a path and returns an Array containing hashes with each article's
  # metadata.

  def get_articles(sub_topics)
    FileUtils::mkdir_p "#{output_dir}/guides"
    sub_topics.map do |sub_topic|
      link = sub_topic.css("a")[0]
      title = link.inner_text
      href = "http://emberjs.com#{link[:href]}"
      $stderr.puts "- #{title}"

      path = href[/(guides\/[^\/]*)\/?.*/, 0] + '.html'
      dirpath = href[/(guides\/[^\/]*)\/?.*/, 1]
      FileUtils::mkdir_p "#{output_dir}/#{dirpath}"

      html = run_shell_command "curl -s #{href}/"
      chapter_doc = Nokogiri::HTML html

      File.open("#{output_dir}/#{path}", 'w') do |f|
        f.puts(chapter_doc.at('.chapter').inner_html)
      end

      {
        title: title,
        path: path
      }
    end
  end
end

# RUN IT! This pulls down the documentation and turns it into the Kindle ebook.

Emberjs.generate