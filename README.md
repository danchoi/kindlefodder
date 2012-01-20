# docs_on_kindle

This project aims to translate web documention for popular software tools and
APIs into Kindle ebooks that are easy to navigate and a pleasure to read while
you're standing in a line at the coffeeshop or sitting on a couch.

The prototype example is Heroku's web documentation:

![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/toc-sm.gif)
![screen](https://github.com/danchoi/docs_on_kindle/raw/master/screenshots/article-sm.gif)

You can download the generated Heroku documentation ebook and transfer it to
your Kindle via USB:

[Download Heroku Guide for Kindle][mobi]

[mobi]:https://github.com/danchoi/docs_on_kindle/raw/master/mobi/heroku-guide.2012-01-20.mobi

Read on if you're interested in learning how the tool works so you can
contribute recipes for turning web documentation for other products and
services into Kindle ebooks.

## Requirements

* Ruby 1.9
* ImageMagick (i.e. the `convert` command)
* Intermediate Nokogiri skills

## How to write a recipe

Go to the [Github issues page][issues] for this project to check if someone is
working on the recipe you had in mind.  If not, post a Github issue saying that
you're working on this recipe and give it the "recipe in progress" label. This
will help prevent unnecessary duplication of effort.

[issues]:https://github.com/danchoi/docs_on_kindle/issues

Fork this project and git clone your fork. `cd` into the cloned git
directory.

Run `bundle install` to make sure you have the required dependencies
(nokogiri and kindlerb) in the gem path.

Create a recipe file in the `recipes/` directory.

Follow the `reciples/heroku.rb` recipe as a model. The pattern should be fairly
straitforward.

Once you finish your recipe, generate the ebook with this command:

    ruby -Ilib recipes/your_new_recipe.rb

If all goes well, you should have a nice Kindle ebook version of the web
documentation you procesed.

Now submit a pull request on your fork so I can pull in your recipe.

All recipe contributors will be recognized and thanked on this page!

## Issues

This project is new and rough around the edges, so please feel welcome to
report issues and contribute to the code. 

