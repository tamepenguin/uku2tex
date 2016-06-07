#!/usr/bin/env ruby
# uku2tex.rb
# converts .uku files to latex for pdf generation

# Modes: inline more (C)text
# Super
#      C
# more text
require 'rqrcode_png'

$mode = 'inline'


song=''

$title = nil
$original = nil
$band = nil
$bard = nil
$copyrighted = nil
$youtube = nil
$tags = nil
$songtext = ''

$verses = 0
$lines = 0
$width = 0




def real_linelength (line)
  if $mode == 'super'
    placeholder = ''
  else
    placeholder = '(\1)'
  end

  line.gsub(/_(.+?)_/, placeholder).length
end




# extracts the header information to global variables $title etc.
# puts the rest after the header into $songtext
# Sooner or later I'll start differentiating between verses and might even treat
# the choruses differently :)
def extract_data(song)
  # Songs have to start with the header, so the next is true
  in_header = true

  song.split("\n").each do |line|
    # Ignore comments. Never hurts to have comments in a file format
    next if line.start_with? "#"

    # First, evaluate the header
    if in_header
      # A single empty line separates the header from the actual song
      if line.match /^\s*$/
        in_header = false
        next
      end

      $title       = line[/^Titel: (.*)/, 1]  if $title == nil
      $original    = line[/^Originaltitel: (.*)/,1 ]  if $original == nil
      $band        = line[/^Band: (.*)/, 1]  if $band == nil
      $bard        = line[/^Barde: (.*)/] if $bard == nil
      $copyrighted = line[/^Copyrighted: (.*)/, 1]  if $copyrighted == nil
      $youtube     = line[/^Youtube: (.*)/, 1]  if $youtube == nil
      $tags        = line[/^Tags: (.*)/, 1]  if $tags == nil
      # Skip parameters
      next if line[/^(Titel: |Originaltitel: |Band: |Barde: |Copyrighted: |Youtube: |Tags: )/]

    else # Not in header
      # puts "Leerzeile" if  line[/^\s*$/]
      $songtext += line.chomp + "\n"
      # Lines increase :)
      $lines += 1
      linelength = real_linelength(line)
      $width = linelength if linelength > $width
    end
  end
end


# Convert the uku chords into something usable for latex and our ukusongbook stylesheet
def convert_chords(song)
  song.gsub(/_(.+?)_/, '\C{\1}')
  # $songtext.gsub(/_(.+?)_/, '\hc{\1}')
end


# Create a QR code $title_qr.png  if the youtube info is set
def write_youtube_qr
  if $youtube
    qr = RQRCode::QRCode.new( 'my string to generate', :size => 4, :level => :h )
    png = qr.to_img                                             # returns an instance of ChunkyPNG
    png.resize(90, 90).save("#{$title}_qr.png")
  end
end


# Add linebreaks, header and footer
def latexify (song)
  songtext = '\begin{ukusong}{%s}
' % [ $title ]

  song.split("\n").each do |line|
     
      songtext += line + '\\\\' +  "\n"
  end
  
  songtext + '\end{ukusong}'
	
end



if ARGV.empty?
  puts "Usage: #{$0} <file to convert  from uku to tex\n"
  exit 1
end

file = ARGV[0]

if File.exists? file
  song = File.read file 
else
  puts "Can't read #{file}."
  exit 1
end










# Separate header information
extract_data song

# move chords from _C_ to \C{C}
song = convert_chords $songtext

write_youtube_qr


puts latexify song




