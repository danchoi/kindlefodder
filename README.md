# Kindlefodder 

Kindlefodder is a Ruby framework and a collection of recipes for translating
websites and webpages into Kindle ebooks that are easy to navigate and a
pleasure to peruse. Web browsers are good for scanning information, but Kindles
are a lot better when you want to block out distractions and actually learn
something.

The ebooks posted here will in most cases be derived from material published
under a Creative Commons license.  I am grateful to the original authors
for writing such good and useful material. They are welcome to take these
ebooks and recipes, modify them, and distribute them under their own name. 

## You can download these ebooks now

Here are a few Kindle ebooks generated with the Kindlefodder framework.  You
can download them and transfer them to your Kindle via USB.

### Heroku Guide

![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/article-sm.gif)

* [Download Heroku Guide for Kindle][heroku-mobi]
* [Heroku Documentation on the Web][heroku-web]

[heroku-mobi]:https://github.com/downloads/danchoi/kindlefodder/heroku-guide.2012-01-20.mobi
[heroku-web]:http://devcenter.heroku.com/categories/getting-started

### Thoughbot Playbook

![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/thoughtbot-toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/thoughtbot-article-sm.gif)

* [Download Thoughtbot Playbook for Kindle][thoughtbot-mobi]
* [Thoughtbot Playbook on the Web][thoughtbot-web]

[thoughtbot-mobi]:https://github.com/downloads/danchoi/kindlefodder/thoughtbot_playbook.2012-01-20.mobi
[thoughtbot-web]:http://playbook.thoughtbot.com/

### Pro Git by Scott Chacon

![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/progit-toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/progit-article-sm.gif)

* [Download Pro Git for Kindle][progit-mobi]
* [Pro Git Book on the Web][progit-web]

If you enjoy the Kindlefodder version, I encourage you to buy the [print
version][progit-print] to support the author.  I own the print version.

[progit-mobi]:https://github.com/downloads/danchoi/kindlefodder/pro_git.2012-01-21.mobi
[progit-web]:http://progit.org/book/
[progit-print]:http://www.amazon.com/Pro-Git-Chacon/dp/1430218339/ref=tmm_pap_title_0?ie=UTF8&qid=1327266631&sr=1-1

### jQuery Documentation

![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/jquery-toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/jquery-article-sm.gif)

* [Download jQuery Documentation for Kindle][jquery-mobi]
* [jQuery Documentation on the Web][jquery-web]

[jquery-mobi]:https://github.com/downloads/danchoi/kindlefodder/jquery.2012-01-21.mobi
[jquery-web]:http://docs.jquery.com/Main_Page

### jQuery Fundamentals by Rebecca Murphey et al.

![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/murphey-toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/murphey-article-sm.gif)

* [Download jQuery Fundamentations for Kindle][murphey-mobi]
* [jQuery Fundamentations on the Web][murphey-web]

[murphey-mobi]:https://github.com/downloads/danchoi/kindlefodder/jquery_fundamentals.2012-01-22.mobi
[murphey-web]:http://jqfundamentals.com/

### Haml/Sass/CoffeeScript Reference

![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/frontend-toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/frontend-article-sm.gif)

* [Download Haml/Sass/CoffeeScript Documentation for Kindle][frontend-mobi]
* [Haml Documentation on the Web][haml]
* [Sass Documentation on the Web][sass]
* [CoffeeScript Documentation on the Web][coffee]

[frontend-mobi]:https://github.com/downloads/danchoi/kindlefodder/frontend_bundle.2012-01-21.mobi
[haml]:http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html
[sass]:http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html
[coffee]:http://coffeescript.org/#comparisons

### Ruby on Rails Guides

![screen](https://github.com/danchoi/docrails_kindle/raw/master/images/screen1-sm.gif)
![screen](https://github.com/danchoi/docrails_kindle/raw/master/images/screen2-sm.gif)

The code used to generate this ebook is actually the evolutionary ancestor to
the kindlefodder project. That code is available in the
[docrails_kindle][docrails_kindle] project.

* [Download Ruby on Rails Guides for Kindle][railsguides-mobi]
* [Ruby on Rails Guides on the Web][railsguides-web]

[railsguides-mobi]:https://github.com/downloads/danchoi/kindlefodder/rails-guide.2012-01-18.mobi
[railsguides-web]:http://guides.rubyonrails.org/
[docrails_kindle]:https://github.com/danchoi/docrails_kindle

### The Art of Unix Programming by Eric Steven Raymond


![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/unix-toc-sm.gif)
![screen](https://github.com/danchoi/kindlefodder/raw/master/screenshots/unix-article-sm.gif)

This one is my personal favorite. 

If you enjoy the Kindlefodder version, I encourage you to buy the [print
version][unix-print] or the official [Kindle version][unix-kindle] as well, to
support the author.  I have both versions.

* [Download The Art of Unix Programming for Kindle][unix-mobi]
* [The Art of Unix Programming on the Web][unix-web]

[unix-print]:http://www.amazon.com/exec/obidos/tg/detail/-/0131429019/104-5607387-8275944?v=glance
[unix-mobi]:https://github.com/downloads/danchoi/kindlefodder/unix.2012-01-22.mobi
[unix-web]:http://www.faqs.org/docs/artu/index.html


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

[issues]:https://github.com/danchoi/kindlefodder/issues


## Issues

This project is new and rough around the edges, so please feel welcome to
report issues and contribute to the code. 

