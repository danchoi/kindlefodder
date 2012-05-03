# encoding: utf-8
require 'kindlefodder'


class TraderJoes < Kindlefodder

  def get_source_files
    @internal_links = {}

    @start_url = "http://www.traderjoes.com/fearless-flyer"
    @start_doc = Nokogiri::HTML run_shell_command("curl -L -s #{@start_url}"), nil, 'UTF-8'
    #@start_doc = Nokogiri::HTML File.read("temp.html"), nil, 'UTF-8'

    sections = extract_sections


    File.open("#{output_dir}/sections.yml", 'w') {|f|
      f.puts sections.to_yaml
    }
    fix_crosslinks sections
  end

   def download_cover_image
    if !File.size?("cover.gif")
      `curl -s 'http://www.traderjoes.com/images/fearless-flyer/logo-fearless-flyer.png' > cover.png`
      run_shell_command "convert cover.png -resize '400x300>' cover.gif"
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
      article_doc = Nokogiri::HTML File.read("#{output_dir}/#{path}"), nil, 'UTF-8'
    else
      html = run_shell_command "curl -s #{full_url}"
      article_doc = Nokogiri::HTML html, nil, 'UTF-8'
      article_doc = article_doc.at(".post")
    end

    # images have relative paths, so fix them
    article_doc.search("h2.title").each {|h2|
      h2.name = 'h3'
    }
    article_doc.search("span").each {|span|
      span.remove_attribute 'style'
    }
    # inline any recipes:
    # http://www.traderjoes.com/recipes/recipe.asp?rid=146
    # example
    # <br><br><br><br><br><br><br><span><span>Smoked Salmon Cucumber Sandwiches—<span><strong><a href="/recipes/recipe.asp?rid=146">Get the recipe!</a></stron
    
    recipe_urls = article_doc.search("a").select {|a| a[:href] =~ %r|^/recipes/|}.map {|a|
     recipe_url = "http://www.traderjoes.com#{a[:href]}" 
     a.remove
     recipe_url
    }.uniq
    recipe_urls.each do |url|
      recipe_html = run_shell_command "curl '#{url}'"
      # Must do this to prevent encoding irregularities:
      recipe_html.force_encoding("UTF-8")
      recipe_content = Nokogiri::HTML(recipe_html, nil, 'UTF-8').at('.oneRecipe')
      recipe_content.search("p.back,.clear,.hr").remove
      p = recipe_content.at("p.title")
      if p
        title_n = p.at(".text")
        title_n.name = 'h3'
        recipe_content.at("img").before title_n
        recipe_content.search("ul").each {|ul| ul[:style] = "clear:both"}
        # recipe_content.at("img").after Nokogiri::XML::Node.new("br", recipe_content)
        p.remove
        puts "Inlining recipe: #{title_n.inner_text}"
        article_doc.at('hr').xpath("./following-sibling::*").each(&:remove)
        article_doc.at('hr').after recipe_content
      end
    end

    # The first one is the main image; the next is a recipe image we don't need to touch
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

    # check for any internal links:
    # Examples:
    # INTERNAL LINK: /fearless-flyer/article.asp?article_id=600&preview=true
    # INTERNAL LINK: /fearless-flyer/article.asp?article_id=599&preview=true
    article_doc.search("a").each {|a|
      if a[:href] =~ %r{^/fearless-flyer/article.asp\?article_id}
        puts "INTERNAL LINK: #{a}"
        # track cross links in map. Key by title (simplest)
        a[:href] = "http://www.traderjoes.com#{a[:href].sub(/&preview=true/, '')}" 
        puts a[:href]
      end
    }

    description = ((p = article_doc.at("p")) && p.inner_text.strip.split(/\s+/)[0, 10].join(' ')) || ''

    res = article_doc.inner_html
    File.open("#{output_dir}/#{path}", 'w:utf-8') {|f| f.puts res}
    return [path, description]
  end

  # Go through all the articles and see if there are any crosslinks
  def fix_crosslinks sections
    # TODO
  end

end

#$use_cached_html = true
if $use_cached_html
  TraderJoes.noclobber = true
end
TraderJoes.generate
