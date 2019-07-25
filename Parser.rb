require 'nokogiri'
require 'curb'
require 'csv'

puts 'Please, enter name of csv-file'
name = gets.encode("UTF-8").chomp

CSV.open(name+'.csv', "wb") do |csv_line|
csv_line << ["Name", "Price", "Image"]

puts 'Please, enter href on subcategory of product,for example: https://www.petsonic.com/snacks-higiene-dental-para-perros/'
url = gets.chomp
#pagination
i = 1
while i < 10 do
if i == 1
urlpag = url
else
urlpag = url+'?p='+i.to_s
end
i = i+1
puts 'Getting information from ' + urlpag
# Parsing
c = Curl::Easy.new(urlpag)
c.perform
page = Nokogiri::HTML(c.body_str)
# Passing on all the products:
page.xpath('//a[@class="product-name"]/@href').each do |el|
c = Curl::Easy.new(el.text)
c.perform
page = Nokogiri::HTML(c.body_str)
# Getting number of combination price-weight in each product
n=0
page.xpath('//span[@class="radio_label"]').each do |el|
n=n+1;
end
# Writting in CSV information about one product
  x=0
  while x <  n  do
  price = page.xpath('//span[@class="price_comb"]')[x].text+''
  #Extracting all the numbers from a string
  pricenum = price.scan(/\d{1,2}[,.]\d{1,2}/)

  image = page.xpath('//span[@id="view_full_size"]/img/@src').text+''
  name = page.xpath('//p[@class="product_main_name"]').text+''
  weight = page.xpath('//span[@class="radio_label"]')[x].text+''
  fullname = name.to_s+"-"+weight.to_s
  csv_line << [fullname.chomp,pricenum[0],image]
  x +=1
  end
end
end
end
