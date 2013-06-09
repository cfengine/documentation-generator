# references.rb: Jekyll Markdown references plugin
#
# Created by Olov Lassus, Public Domain license.
# Version 1.0
# https://github.com/olov/jekyll-references
#
# CHANGES
# 2013-05-06: v1.0
# * Updated to support Jekyll 1.0
#   (should still work with older Jekyll versions)
# * Works on all Markdown transformations, files or snippets
#
# USAGE
# Add references.rb to your _plugins directory (create it if needed).
# Create a file named _references.md in your Jekyll site root,
# then add your markdown reference-style link definitions to it.
# For example:
#   [google]: http://www.google.com  "Google it!"
#   [wiki]: http://wikipedia.org  "Online Encyclopedia"
#   [id]: url  "tooltip"
#
# You can now reference these links in any markdown file.
# For example:
# [Google][google] is a popular search engine and [Wikipedia][wiki] an
# online encyclopedia.

module Jekyll
  module Convertible
    alias old_read_yaml read_yaml
    @@refs_content = nil

    def read_yaml(base, name)
      # loads file, sets @content, @data
      old_read_yaml(base, name)

      # only alter markdown files
      md_class = ((defined? MarkdownConverter) ? MarkdownConverter : Jekyll::Converters::Markdown)
      return unless converter.instance_of? md_class

      # read and cache content of _references.md
      if @@refs_content.nil?
        refs_path = File.join(site.source, "_references.md")
        @@refs_content = if File.exist?(refs_path) then File.read(refs_path)
                         else "" end
      end

      # append content of _references.md, whatever it is
      @content += "\n" + @@refs_content
    end
  end
end