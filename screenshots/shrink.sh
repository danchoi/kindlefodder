#!/bin/bash
convert -resize '300X400>' $1-toc.png $1-toc-sm.gif
convert -resize '300X400>' $1-article.png $1-article-sm.gif
