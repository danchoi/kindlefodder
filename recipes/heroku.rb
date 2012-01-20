
=begin

The internals of a recipe are up to you, but a recipe should do at least the
following:

First, require 'docs_on_kindle' and subclass DocsOnKindle.

Second, contain a #get_sources_files method that does two things:

1. Save a sections.yml to the path returned by the superclass's output_dir()
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

2. Save HTML fragments of the article content at the path values indicated in
the sections.yml above

The recipe class should also contain a #document method that returns a metadata
hash as below. The masthead and cover values seem optional. But if you fill
them in, use absolute paths.


=end


require 'docs_on_kindle'

class Heroku < DocsOnKindle 



  # These next two methods must be implemented.

  def get_source_files

    # The start_url is any webpage that will contain the navigation structure
    # of the documentaion

    start_url = "http://devcenter.heroku.com/categories/add-on-documentation" 

    @start_doc = Nokogiri::HTML run_shell_command("curl -s #{start_url}")

    File.open("#{output_dir}/sections.yml", 'w') {|f|

      # extract_sections() is defined below.  It gets the sections of the ebook
      # out of the webpage docs navigation sidebar.

      f.puts extract_sections.to_yaml
    }
  end

  # This method is for the ebook metadata.

  def document 
    {
      # Fill these in with full paths if available
      # No sure yet what the proper dimensions are.

      'cover' => nil,
      'masthead' => nil,
    }
  end




  # The methods below are not required methods. They are this recipe's
  # implementation for generating the required sections.yml and article
  # fragment files.



  # This method extracts the sections from the html sidebar at start_url

  # This method returns an Array of elements with the Hash structure you
  # see at the end.

  def extract_sections
    @start_doc.search('select[@id=quicknav] option').map {|o| 
      title = o.inner_text
      $stderr.puts "#{title}"
      articles_list = run_shell_command "curl -s http://devcenter.heroku.com#{o[:value]}"
      { 
        title: title,
        articles: get_articles(articles_list)
      }
    }
  end
  
  # For each section, this method it saves the HTML fragment of each article's
  # content to a path and returns an Array containing hashes with each article's
  # metadata.

  def get_articles html
    FileUtils::mkdir_p "#{output_dir}/articles"
    category_page = Nokogiri::HTML html 
    xs = category_page.search("ul.articles a").map {|x|
      title = x.inner_text.strip
      href = x[:href] =~ /^http/ ? x[:href] : "http://devcenter.heroku.com#{x[:href]}" 
      $stderr.puts "- #{title}"

      # Article content will be saved to path articles/filename
      path = "articles/" + href[/articles\/([\w-]+)(#\w+|)$/, 1]

      # Save just the HTML fragment that contains the article text. Throw out everything else.

      html = run_shell_command "curl -s #{href}"
      article_doc = Nokogiri::HTML html
      File.open("#{output_dir}/#{path}", 'w') {|f| f.puts(article_doc.at('article').inner_html)}

      # Return the article metadata hash for putting into the section's articles array

      { 
        title: title,
        path: path
      }
    }
  end

end

# RUN IT! This pulls down the documentation and turns it into the Kindle ebook.

Heroku.generate
