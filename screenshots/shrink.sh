#!/bin/bash
convert -resize '300X400>' $1-toc.gif $1-toc-sm.gif
convert -resize '300X400>' $1-article.gif $1-article-sm.gif
