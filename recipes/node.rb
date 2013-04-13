
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

class Node < Kindlefodder 



  # These next two methods must be implemented.

  def get_source_files

    @node_version = ARGV.last && ARGV.last != "compile[node.rb]" ? "v#{ARGV.last}" : "latest"

    # The start_url is any webpage that will contain the navigation structure
    # of the documentaion

    @start_url = "http://nodejs.org/docs/#{@node_version}/api/"

    File.open("#{output_dir}/sections.yml", 'w') {|f|

      # extract_sections() is defined below.  It gets the sections of the ebook
      # out of the webpage docs navigation sidebar.

      f.puts extract_sections.to_yaml
    }
  end

  # This method is for the ebook metadata.

  def document 
    {
      'title' => "Node.js (#{@node_version}) Manual & Documentation",
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
    articles_list = run_shell_command "curl -s #{@start_url}"
    [{ 
      title: "API Documentation",
      articles: get_articles(articles_list)
    }]
  end
  
  # For each section, this method saves the HTML fragment of each article's
  # content to a path and returns an Array containing hashes with each article's
  # metadata.

  def get_articles html
    FileUtils::mkdir_p "#{output_dir}/articles"
    category_page = Nokogiri::HTML html
    xs = category_page.search("#apicontent a").map {|x|

      title = x.inner_text.strip
      href = x[:href] =~ /^https?:/ ? x[:href] : "#{@start_url}#{x[:href]}"
      $stderr.puts "- #{title}"

      # Article content will be saved to path articles/filename
      path = "articles/" + x[:href]

      # Save just the HTML fragment that contains the article text. Throw out everything else.
      html = run_shell_command "curl -s #{href}"
      
      article_doc = Nokogiri::HTML html
      article_doc.search("a.mark").remove()
      content = article_doc.at('#apicontent').inner_html
      
      File.open("#{output_dir}/#{path}", 'w') {|f| f.puts(content)}

      # Return the article metadata hash for putting into the section's articles array
      { 
        title: title,
        path: path
      }
    }
  end

end

# RUN IT! This pulls down the documentation and turns it into the Kindle ebook.

Node.generate
