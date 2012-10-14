#!/usr/bin/env ruby

require 'fileutils'

tmpFile = open("tmp-file", "w")
tmpFile.puts "---"
tmpFile.puts "layout: post"

open(ARGV[0]) { |file|
  inHead = true
  inContent = false
  date = "2012-10-14"
  title = "tmp-file"
  categories = "dev"
  tags = ""
  file.readlines.each{ |line|
    if line.start_with?("Date:")
      date = line.split(":")[1].strip
    elsif line.start_with?("Title:")
      title = line.split(":")[1].strip
    elsif line.start_with?("Category:")
      categories = line.split(":")[1].strip
    elsif line.start_with?("Tags:")
      tags = line.split(":")[1].strip
    elsif line.match(/^[A-Z][a-z]+: [^:]+$/)
    else
      inHead = false
    end

    if ! inHead && ! inContent
      tmpFile.puts "title: \"#{title}\""
      tmpFile.puts "date: #{date}"
      tmpFile.puts "comments: true"
      tmpFile.puts "categories: #{categories}"
      tmpFile.puts "tags: [#{tags}]"
      tmpFile.puts "---"

      inContent = true
    end

    if ! inHead && inContent
      tmpFile.puts line
    end
  }

  tmpFile.close

  FileUtils.mv "tmp-file", "#{date}-#{title.downcase.split.join("-")}.markdown"
}
