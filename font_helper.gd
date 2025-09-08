extends Node

var KREON_REGULAR
var KREON_REGULAR_CARDNAME
var KREON_REGULAR_CARDDESCRIPTION
var KREON_BOLD


func _init():
	var install_location = "C:/Program Files (x86)/Steam/steamapps/common/SlayTheSpire/desktop-1.0.jar"
	var reader = ZIPReader.new()
	var err = reader.open(install_location)
	var pba 
	pba = reader.read_file("font/Kreon-Regular.ttf")
	KREON_REGULAR = FontFile.new()	
	KREON_REGULAR.data=pba
	KREON_REGULAR_CARDNAME = FontFile.new()	
	KREON_REGULAR_CARDNAME.data=pba	
	KREON_REGULAR_CARDNAME.set_extra_spacing(0,TextServer.SPACING_GLYPH,2)
	KREON_REGULAR_CARDDESCRIPTION = FontFile.new()	
	KREON_REGULAR_CARDDESCRIPTION.data=pba	
	KREON_REGULAR_CARDDESCRIPTION.set_extra_spacing(0,TextServer.SPACING_BOTTOM,-5)	
	pba = reader.read_file("font/Kreon-Bold.ttf")
	KREON_BOLD = FontFile.new()	
	KREON_BOLD.data=pba

	
	reader.close()

static func render_to_card_front(text,card,font,pos):
	var trc = TextRenderingViewport.create(text,card,FontHelper.KREON_REGULAR,Vector2i(pos.x,pos.y))
	Globals.MAIN().add_child(trc)
	trc.global_position=Vector2(trc.get_viewport_rect().size)

static func render_card_description(text,card,font):
		#var subview = SubViewport.new()	
	text=fit_description_to_card(text)
	render_to_card_front("[color=#00000088]"+text+"[/color]",card,font,Vector2i(808/2+3,700+3))
	render_to_card_front(text,card,font,Vector2i(808/2,700))

static func fit_description_to_card(text)->String:
	text="[font_size=48]"+text+"[/font_size]"
	return text

#static func fit_description_to_card(text)->String:
	#var textline=TextLine.new()			
	#var words=text.split(" ")
	#var lines=Array()
	#var line=""
	#for word in words:
		#var nextword=TextLine.new()
		#nextword.add_string(word,FontHelper.KREON_REGULAR, 16)
		#if(textline.get_line_width()+nextword.get_line_width()>400):
			#lines.append(line)
			#textline=TextLine.new()	
			#line=""
		#if(line!=""):
			#line=line+" "
			#textline.add_string(" ",FontHelper.KREON_REGULAR, 16)		
		#line=line+word
		#textline.add_string(word,FontHelper.KREON_REGULAR, 16)
		##TODO: final word isn't added to line
		##TODO: final line isn't added to word
		##TODO: can we make this easier with a RichTextLabel function somehow?
	#for l in lines:
		#print(l)
	#
	#return text	
