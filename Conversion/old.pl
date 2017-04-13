

#italics on
	 s/\.us;/\<hi rend=\"italic\">/g;
	 s/\.us on/\<hi rend=\"italic\">/g;

#italics off
	 s/\@/<\/hi>/g;
	 s/\.us off/\<\/hi>/g;

#removes .ct
	 s/\.ct//g;




#Line Breaks
	s/\.br\;/\<br\/>/g;

#.il meaning "indent line" 
	s/\.il (\d+)/<\?formatting indent-line $1\?>/g;

#TABLES

#Changes .tb command to  command
	s/\.tb(.*?)\;/\n<!--\.tb $1-->/g;


#Changes .ll (line length) command 
	s/\.ll. (\d+)/<\?formatting line-length $1\?>/g;	

#Changes tabs to cells
#	s/\}/\<\/cell\>\<cell\>/g;

#.et (end table) changes to </cell></row></table> 
	s/\.et/<\/table>/g;

#.pa becomes a new table with two cells

	s/\.pa/<\/td><\/tr><\/table><\/p><p><table rend=\"noborder\"><tr rend=\"top\"><td><\/td><td><\/td>/g;

#special case cell division
	s/<\/note>}(.*?)<\/note>/<\/td><td>$1<\/td><\/td>/g;


#.bt changes to <table>
	s/\.bt/\<table xhtml:border=\"0\">/g;
	s/\.\'bt/\<table xhtml:border=\"0\">/g;

#.'etbt changes to </cell></row><row rend=\"top\"><cell>
	s/\.\'etbt/<tr valign=\"top\"><td>/g;
	s/\.\etbt/<tr valign=\"top\"><td>/g;

#.'ct becomes <row><cell>
	s/\.\'ct/<tr valign=\"top\"><td>/g;

#Translation of the ".end" tag
#".end" appears to signal an "end ruler" command
#used both to revert to standard tabs or signal new tabs
#Should be replaced by </table><table> command
	s/\.end/\n/g;

#Comment tag
	 s/^\.cm(.*?)/\n<!-- $1 -->\n/g;
	 s/^\.\'cm(.*?)/\n<!-- $1 -->\n/g;

#Div tags (div0> will equal "volume" and must be added by hand


#turns .year into <div1 type="year"> plus head
#See note below
	 s/\.year\;\.(\d)(\d)(\d)(\d)\.\./\n\n<div1 type\=\"year\">\n<head>$1$2$3$4<\/head>\n\n/g;
	 s/\.year\;(\d)(\d)(\d)(\d)./\n\n<div1 type\=\"year\">\n<head\>$1$2$3$4<\/head>\n\n/g;

#turns .year [dddd] into a <hi rend="bold">
	 s/\.year\;(\[.*?\])/\n\n<hi rend\=\"bold\">$1<\/hi>/g;
	
#NOTE:  <div1) tags occur before <div2> tags
#TEI editor will need to fix this nesting problem manually
	 s/\.cashyear/<\/div2>\n<div2 type\="entry">\n<head>Cash Accounts<\/head>\n\n/g;
	 s/\.lawyear/<\/div2>\n<div2 type\="entry">\n<head>Legal Notations<\/head>\n\n/g;

#This one is for Miscellaneous "Memoranda" and "Records"

#NOTE:  Currency Chart and Wine Lists labeled as ".miscyear"
#	 s/\.miscyear/<\/div3>\n<\/div2>\n<div2 type\="entry">\n<head>[type head here]<\/head>\n\n/g;	
#	 s/\.MsTJyear/<\/div3>\n<\/div2>\n<div2 type\="entry">\n<head>Martha Jefferson's Accounts<\/head>\n\n/g;
#	 s/\.weather/<\/div3>\n<\/div2>\n<div2 type\="entry">\n<head>Meteorological Records<\/head>\n\n/g;

#turns .month into 
#turns .month into <table> with head as month
	 s/\.month;(.*?)}(.*?)}}/<\/table><\/p>\n<p><table>\n<tr valign\=\"top\"><td><date value\=\"\">$1<\/date><\/td><td>$2/g;
	 s/\.month;(.*?)}(.*?)}/<\/table><\/p>\n<p><table>\n<tr valign\=\"top\"><td><date value\=\"\">$1<\/date><\/td><td>$2/g;
	 s/\.month;(.*?)(.*?)/<\/table><\/p>\n<p><table>\n<tr valign\=\"top\"><td><date value\=\"\">$1<\/date><\/td><td>$2/g;

#	 s/\.month;(.*?)}/<\/list>\n\n<list>\n<head>$1<\/head>\n<item>/g;
#	 s/\.month;(.*?).?/<\/list>\n\n<list>>\n<head>$1<\/head>\n/g;

#closes <item> tag before </list> tag

#	 s/<\/list>/<\/item>\n<\/list>/g;
      
#	 s/\.month.(...\.)}(\d)\.}}/\n<\/div2\>\n\n<div2 type\=\"month\">\n<head>$1<\/head>\n<div3 type\="day"><head>$2<\/head>\n<\/p><p>/g;
#        s/\.month.(...\.)}(\d)(\d)\.}}/\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2$3<\/head>\n<\/p><p>/g;

#	 s/\.month.(May\.)}/(\d)\.}}\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2<\/head>\n<\/p><p>/g;
#        s/\.month.(May\.)}/(\d)\.}}\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2$3<\/head>\n<\/p><p>/g;

#	 s/\.month.(June\.)}(\d)\.}}/\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2<\/head>\n<\/p><p>/g;
#        s/\.month.(June\.)}(\d)\.}}/\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2$3<\/head>\n<\/p><p>/g;

#	 s/\.month.(July\.)}(\d)\.}}/\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2<\/head>\n<\/p><p>/g;
#        s/\.month.(July\.)}(\d)\.}}/\n\<\/div2\>\n\n\<div2 type\=\"month\"\>\n\<head\>$1\<\/head\>\n<div3 type\="day"><head>$2$3<\/head>\n<\/p><p>/g;



#turns .day into table row
	 s/\.day\;(.*?)\}\}/<\/td><\/tr>\n<tr valign=\"top\"><td><date value\=\"\">$1<\/date><\/td><td>/g;


#turns .sday tag into <item> tags
	 s/.sday\;/<\/td><\/tr>\n<tr valign=\"top\"><td><\/td><td>\n/g;

#turns .xday tag into </p><p> 
	 s/\.xday\;(.*?)\}/<\/td><\/tr>\n<tr valign=\"top\"><td>$1<\/td><td>/g;
#	 s/.xday\;/<\/p><p>\n\n/g;

#removes } bracket around X
	 s/}(.*?)}/$1\&nbsp\;&nbsp\;/g;


#.daylist changed for </p><p>
#	s/\.daylist\;/\n<\/p><p>\n\n/g;
         s/\.daylist\;(.*?)/<\/td><\/tr>\n<tr valign=\"top\"><td>$1<\/td><td>/g;

#turns .xlist tag into table row
	 s/\.xlist\;(.*?)/<\/td><\/tr>\n<tr valign=\"top\"><td>$1<\/td><td>/g;

#kills .ce tag (which just causes one word to hang--is not useful)
	 s/\.ce\;/ /g;