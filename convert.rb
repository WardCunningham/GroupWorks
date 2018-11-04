# construct pages for groupworks pattern language
# usage: cd GroupWorks; sh convert.rb

require 'json'
require 'base64'

@site = '/Users/ward/.wiki/group.localhost'

def random
  (1..16).collect {(rand*16).floor.to_s(16)}.join ''
end

def is_numeric? item
	begin Integer(item) ; true end rescue false
end


def slug title
  title.gsub(/\s/, '-').gsub(/[^A-Za-z0-9-]/, '').downcase()
end

def clean text
  text.gsub(/’/,"'").gsub(/&nbsp;/,' ').gsub(/^\n\s*/, '').gsub(/Therefore/,"<b>Therefore</b>")
end

def url text
  text.gsub(/(http:\/\/)?([a-zA-Z0-9._-]+?\.(net|com|org|edu)(\/[^ )]+)?)/,'[http:\/\/\2 \2]')
end

# todo: add story and provenance
def create title, story
  {'type' => 'create', 'id' => random, 'date' => Time.now.to_i*1000, 'item' => {'title' => title, 'story' => story}}
end

def item type, text
  {'type' => type, 'text' => text, 'id' => random()}
end

def paragraph text
  {'type' => 'paragraph', 'text' => text, 'id' => random()}
end

def related titles
  bullets = titles.map{|title| "- [[#{title}]]"}.join("\n")
  {'type' => 'markdown', 'text' => bullets, 'id' => random()}
end

def graphed titles
  bullets = titles.map{|title| "- [[#{title}]]"}.join("\n")
  {'type' => 'markdown', 'graph' => true, 'text' => bullets, 'id' => random()}
end

def image name
  tag = "<img width=100% src=http:/assets/postcards/#{name}.jpg>"
  {'type' => 'html', 'text' => tag, 'id' => random()}
end

def icon name
  image = File.read "category-images/#{name.split(' ')[0].downcase} category icon.jpg"
  data = 'data:image/jpg;base64,' + Base64.strict_encode64(image)
  item 'html', "<div style=\"float:right;\"><img width=100px; src=#{data}></div>"
end

def page title, story, provenance=nil
  page = {'title' => title, 'story' => story, 'journal' => [create(title, story)]}
  page['journal'][0]['provenance'] = provenance if provenance
  File.open("#{@site}/pages/#{slug(title)}", 'w') do |file|
    file.write JSON.pretty_generate(page)
  end
end

# [
#   {
#     "Pattern Card": "Aesthetics of Space",
#     "Image Title": "NatureRoom1",
#     "Image": "https://groupworksdeck.org/sites/default/files/styles/thumbnail/public/upload/patterns/NatureRoom1_large.JPG?itok=wzZvHglV",
#     "Creator": "Peggy Holman",
#     "Permission Status": "permission given",
#     "Permission Notes": "Peggy gave Tom Atlee permission by email 31Mar2011",
#     "Size Notes": "2592 x 1944"
#   },

@picts = JSON.parse File.read 'picts.json'
@cred = "Group Works: A Pattern Language for Bringing Life to Meetings and Other Gatherings"
def credits title
  cred = [@cred]
  pict = @picts.find{|pict| pict['Pattern Card'] == title}
  if pict
    cred.push "Image #{pict['Image Title']}"
    cred.push "Creator #{pict['Creator']}"
    cred.push "Status #{pict['Permission Status']}"
    cred.push "Notes #{pict['Permission Notes']}"
  end
  cred.join ', '
end

# [
#   {
#     "name": "Aesthetics of Space",
#     "pic": "http://grouppatternlanguage.org/files/NatureRoom1+pattern_image-medium-31811.JPG",
#     "heart": "Gathering places that are beautiful, comfortable, functional, and creatively designed to serve the purpose of the meeting call forth participants' best life energy to contribute. Thoughtfully arrange the space and decor to inspire, focus, and sustain the group's work.",
#     "category": "Context",
#     "related": [
#       "Circle",
#       "Gaia",
#       "Hosting",
#       "Power of Constraints",
#       "Power of Place",
#       "Preparedness",
#       "Nooks in Space and Time"
#     ]
#   },

piles = Hash.new { |hash, key| hash[key] = [] }
cards = JSON.parse File.read 'cards.json'
cards.each do |card|
  name = card['name'].gsub(/ /,'_').gsub(/,/,'')
  page card['name'], [
    paragraph(card['heart']),
    image(name),
    graphed(card['related']),
    paragraph("See more [[#{card['category']}]]")
  ], credits(card['name'])
  piles[card['category']].push card['name']
end


# [
#   {
#     "name": "Intention",
#     "description": "Concentrate on serving the larger purpose for the gathering and how it is enacted. Why are we here? What’s our shared passion? What we are aiming to accomplish?  Includes addressing the longer term meaning and consequence of this event or series."
#   },

categories = JSON.parse File.read 'categories.json'
categories.each do |category|
  page category['name'], [
    icon(category['name']),
    paragraph(category['description']),
    related(piles[category['name']]),
    paragraph("See all [[Categories]]"),
    item('transport', 'GRAPH POST http://eu.wiki.org:4010/graphviz')
  ], @cred
end


# https://groupworksdeck.org/patterns_by_category

page "Categories", [
  paragraph("We have divided up the patterns into this set of nine categories. Each category represents a group need addressed by that set of patterns."),
  related(categories.map{|category| category['name']})
], @cred

`rm -f #{@site}/status/sitemap.*`

