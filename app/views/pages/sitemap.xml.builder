xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @public_urls.each do |url|
    xml.url do
      xml.loc url
      xml.lastmod Date.current.iso8601
      xml.changefreq "daily"
      xml.priority "0.8"
    end
  end
end
