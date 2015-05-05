#!/usr/bin/env ruby

require 'net/https'
require 'uri'
require 'nokogiri'
require 'fileutils'

def download(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == "https"
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    result = nil
    http.start do
        http.request_get(uri.path) do |res|
            result = res.body
        end
    end

    result
end

def save(url, local_path)
    unless File.exists? local_path
        puts "Downloading #{local_path}"
        FileUtils.mkdir_p File.dirname(local_path)
        File.write(local_path, download(url))
        sleep 0.1
    end
end

FileUtils.mkdir_p 'content'
FileUtils.mkdir_p 'content/1'
FileUtils.mkdir_p 'content/2'

save 'http://aosabook.org/en/', 'content/index.html'

html = Nokogiri::HTML(File.read('content/index.html'))
table = "<html>\n"
table << "   <body>\n"
table << "     <h1>Table of Contents</h1>\n"
table << "     <span style=\"text-indent:0pt\">\n"
html.css('div.span6')[1].css('table')[0].css('tr').each do |tr|
    # puts tr.css('td')[1]['href']
    a = tr.css('td')[1].css('a')[0]
    link = a['href']
    title = a.text
    title = tr.css('td')[0].text + ' ' + title unless tr.css('td')[0].text.length == 0
    table << "        <a href=\"#{link}\">#{title}</a><br/>\n"
    save "http://aosabook.org/en/#{link}", "content/1/#{link}"
end
table << "     </span>\n"
table << "   </body>\n"
table << "</html>\n"
File.write('content/1/index.html', table)

table = "<html>\n"
table << "   <body>\n"
table << "     <h1>Table of Contents</h1>\n"
table << "     <span style=\"text-indent:0pt\">\n"
html.css('div.span6')[0].css('table')[0].css('tr').each do |tr|
    a = tr.css('td')[1].css('a')[0]
    link = a['href']
    title = a.text
    title = tr.css('td')[0].text + ' ' + title unless tr.css('td')[0].text.length == 0
    table << "        <a href=\"#{link}\">#{title}</a><br/>\n"
    save "http://aosabook.org/en/#{link}", "content/2/#{link}"
end
table << "     </span>\n"
table << "   </body>\n"
table << "</html>\n"
File.write('content/2/index.html', table)

FileUtils.mkdir_p 'content/1-book'
FileUtils.mkdir_p 'content/2-book'

Dir.glob("content/[1-2]/*.html") do |file|
    html = Nokogiri::HTML(File.read(file))
    new_file = file.sub(/\/([1-2])\//, "/\\1-book/")
    html.css('link').each do |link|
        save "http://aosabook.org/en/#{link['href']}", File.join(File.dirname(new_file), link['href'])
    end
    html.css('img').each do |img|
        save "http://aosabook.org/en/#{img['src']}", File.join(File.dirname(new_file), img['src'])
    end
    html.css('div.hero-unit a.pull-right').remove
    File.write(new_file, html.to_html)
end
