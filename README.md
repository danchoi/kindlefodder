# docs_on_kindle

This project aims to translate web documention for popular software tools and
APIs into Kindle ebooks that are easy to navigate and a pleasure to read.


Here are a few example Kindle ebooks generated with docs_on_kindle.
You can download them and transfer them to your Kindle via USB.

### Heroku Guide

![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/toc-sm.gif)
![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/article-sm.gif)

* [Download Heroku Guide for Kindle][heroku-mobi]
* [Heroku Documentation on the Web][heroku-web]

[heroku-mobi]:https://github.com/downloads/danchoi/docs_on_kindle/heroku-guide.2012-01-20.mobi
[heroku-web]:http://devcenter.heroku.com/categories/getting-started

### Thoughbot Playbook

![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/thoughtbot-toc-sm.gif)
![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/thoughtbot-article-sm.gif)

* [Download Thoughtbot Playbook for Kindle][thoughtbot-mobi]
* [Thoughtbot Playbook on the Web][thoughtbot-web]

[thoughtbot-mobi]:https://github.com/downloads/danchoi/docs_on_kindle/thoughtbot_playbook.2012-01-20.mobi
[thoughtbot-web]:http://playbook.thoughtbot.com/

### Pro Git by Scott Chacon

![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/progit-toc-sm.gif)
![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/progit-article-sm.gif)

* [Download Pro Git for Kindle][progit-mobi]
* [Pro Git Book on the Web][progit-web]

[progit-mobi]:https://github.com/downloads/danchoi/docs_on_kindle/pro_git.2012-01-21.mobi
[progit-web]:http://progit.org/book/

### jQuery Documentation

![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/jquery-toc-sm.gif)
![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/jquery-article-sm.gif)

* [Download jQuery Documentation for Kindle][jquery-mobi]
* [jQuery Documentation on the Web][jquery-web]

[jquery-mobi]:https://github.com/downloads/danchoi/docs_on_kindle/jquery.2012-01-21.mobi
[jquery-web]:http://docs.jquery.com/Main_Page

### Haml/Sass/CoffeeScript Reference

![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/frontend-toc-sm.gif)
![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/frontend-article-sm.gif)

* [Download Haml/Sass/CoffeeScript Documentation for Kindle][frontend-mobi]
* [Haml Documentation on the Web][haml]
* [Sass Documentation on the Web][sass]
* [CoffeeScript Documentation on the Web][coffee]

[frontend-mobi]:https://github.com/downloads/danchoi/docs_on_kindle/frontend_bundle.2012-01-21.mobi
[haml]:http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html
[sass]:http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html
[coffee]:http://coffeescript.org/#comparisons

### Ruby on Rails Guides

![screen](https://github.com/danchoi/docrails_kindle/raw/master/images/screen1-sm.gif)
![screen](https://github.com/danchoi/docrails_kindle/raw/master/images/screen2-sm.gif)

The code used to generate this ebook is actually the evolutionary ancestor to the
docs_on_kindle project. Both code and ebook are available [here][docrails_kindle].

[docrails_kindle]:https://github.com/danchoi/docrails_kindle


* * *

# Writing your own ebook recipes

Read on if you're interested in learning how to contribute recipes for turning
web documentation for other products and services into Kindle ebooks.

## Requirements

* Ruby 1.9
* ImageMagick (i.e. the `convert` command)
* You must be a fairly good at slicing and dicing HTML with [Nokogiri][nokogiri] 

[nokogiri]:http://nokogiri.org/

Also, download Amazon's [KindleGen 2][kindlegen] tool and put it on your PATH.

[kindlegen]:http://www.amazon.com/gp/feature.html?ie=UTF8&docId=1000234621

## How to write a recipe

Fork this project and git clone your fork. `cd` into the cloned git
directory.

Run `bundle install` to make sure you have the required dependencies
(nokogiri and kindlerb) in the gem path.

Create a recipe file in the `recipes/` directory.

Follow the `recipes/heroku.rb` recipe as a model. The requirements of a recipe
should be fairly simple and straightforward.

Once you finish your recipe, generate the ebook with this command:

    ruby -Ilib recipes/your_new_recipe.rb

If all goes well, you should have a nice Kindle ebook version of the web
documentation you processed.

Now submit a pull request on your fork so I can pull in your recipe.

All recipe contributors will be recognized and thanked heartily on this page.

If you're working on a recipe, you may want post a [Github issue][issues]
saying what you're working on and give it the "recipe in progress"
label. This will help prevent unnecessary duplication of effort.

[issues]:https://github.com/danchoi/docs_on_kindle/issues


## Issues

This project is new and rough around the edges, so please feel welcome to
report issues and contribute to the code. 

