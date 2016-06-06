# uku2tex.rb
# converts .uku files to latex for pdf generation

# Modes: inline more (C)text
# Super
#      C
# more text
require 'rqrcode_png'

$mode = 'inline'


song='Titel: Buecken verboten
Originaltitel: Küssen verboten!
Band: Die Prinzen
Barde: Jago
Copyrighted: N
Youtube: https://www.youtube.com/watch?v=sX-kH7KeAwU
Tags: Dilli Chords

Willst mich _G_befördern, hast auch _C_schon einen stehn
Ich muß _G_sagen, das kann ich _D_gut verstehn
Du braust mir _G_Tränke und stehst _C_Wache für mich
Bei´n _G_Antare, hab ich´s _D_gut erwischt
Doch da _C_gibt es eine Sache, die ich _G_gar nicht leiden kann
Kommen _C_deine beiden Backen zu _D_nah an mich ran...

Ref.: Bücken ver_G_boten, bücken ver_D_boten
Bücken ver_G_boten, streng ver_A_boten,
_G_Keiner der Blau-_D_Weiß hier trägt
Der _Em_hat mir das geglaubt : _D_Bücken ist bei mir nicht er_G_laubt!

Schon als Rekrut, ja, ich war siebzehn Jahre alt
Da war ein Priester in mich total verknallt
Ging ich in´ Schlaufraum kam er hinter mir her
Und in der Dusche wollte er noch viel mehr
Er dachte, daß er mich mit  ´ner Beförd´rung kaufen kann
Er bückte sich und bot mir seine Backen an....'



template='
\begin{multicols*}{2}
\begin{song}{title}{}

\end{song}
\end{multicols*}

'
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

    else
      # puts "Leerzeile" if  line[/^\s*$/]
      # Add \\ for line breaks. We're not trying to create a diploma thesis here
      $songtext += line.chomp + '\\\\' + "\n"
      # Lines increase :)
      $lines += 1

      # Remove
      linelength = real_linelength(line)
      $width = linelength if linelength > $width
    end
  end
end


def convert_chords(song)
  $songtext.gsub(/_(.+?)_/, '\C{\1}')
  # $songtext.gsub(/_(.+?)_/, '\hc{\1}')
end

def write_youtube_qr
  if $youtube
    qr = RQRCode::QRCode.new( 'my string to generate', :size => 4, :level => :h )
    png = qr.to_img                                             # returns an instance of ChunkyPNG
    png.resize(90, 90).save("#{$title}_qr.png")

    puts "wrote #{$title}_qr.png"
  else
    puts 'No Youtube link to write'
  end
end


def analyze_song (song)


end



def latexify (song)

end





# Separate header information
extract_data song
puts "#{$lines} Lines, broadest line is #{$width}"


# move chords from _C_ to \C{C}
song = convert_chords song
write_youtube_qr

# Embed song and metadata into includable Latex






