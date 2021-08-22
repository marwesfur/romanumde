<?xml version="1.0" encoding="utf-8"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"> 
 
  <xsl:output method="html"
    version="1.0"  
    indent="yes"  
    encoding="utf-8"  
    media-type="text/xml"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    omit-xml-declaration="yes"/>  <!-- ohne das würde der EI6 in den Quirks-Mode wechseln. -->

<!-- /////////////////////////  Variablen ///////////////////////// -->
	<!-- Art des Textes (poetry, prose) -->
 	<xsl:variable name="texttype" select="/translation/description/textkind" />

	<!-- SiteID (für's Erstellen von Kommentaren) -->
	<xsl:variable name="siteid" select="/siteid" />



<!-- /////////////////////////  Seitenumfeld ///////////////////////// -->
	<!-- Header und Footer -->
 	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title>
				Romanum - <xsl:value-of select="/translation/description/author"/>: <xsl:value-of select="/translation/description/title"/> (<xsl:value-of select="/translation/description/snippet"/>)
			</title>
			<link rel="stylesheet" media="screen" type="text/css" href="../../../base.css"/>
			<link rel="stylesheet" media="print" type="text/css" href="../../../print.css"/>
			
			<script src="../../js/prototype.js" type="text/javascript"></script>
			<script src="../../js/comments.js" type="text/javascript"></script>
			<!-- <script src="../../js/scriptaculous.js" type="text/javascript"></script> -->


		</head>
		<body>
		
		<div id="container">
			<div id="pageHeader">
				<div id="navigation">
					<ul>
						<li class="welcome"><a  title="" href="../../../index.html">Startseite</a></li>
						<li class="translation on"><a title="" href="../../index.html">Übersetzungen</a></li>
						<li class="impressum"><a title="" href="../../../impressum.html">Impressum</a></li>
						<li class="datenschutz"><a title="" href="../../../datenschutz.html">Datenschutz</a></li>
					</ul>
				</div>
				<a href="index.html"><h1 id="title">Romanum</h1></a>
			</div>
			<div id="contents">

				<div class="infobox">
					<div class="top"></div><div class="main">
					<p><b>Navigation:</b></p>
					<ul>
						<xsl:apply-templates select="/translation/description/navigation/previous"/>
						<xsl:apply-templates select="/translation/description/navigation/next"/>
					</ul>
					</div><div class="bottom"></div>
				</div>
		
				<h2>
					<xsl:value-of select="/translation/description/author"/> - 
					<xsl:value-of select="/translation/description/title"/>
					(<xsl:value-of select="/translation/description/snippet"/>)
				</h2>
				<p class="translator">
					Übersetzt von
					<xsl:value-of select="/translation/description/translator"/>
				</p>
				
				<!-- Gliederung -->
				<xsl:apply-templates select="translation/structure" />
				
				<!-- Hier nun der eigentliche Inhalt (Text) -->
				<xsl:apply-templates select="translation/text"/>
			</div>
			
			<div id="footer">
				<div id="print">
					<a href="javascript:window.print()">Diesen Text drucken</a>
				</div>
			</div>
		</div>
		
		</body>
		</html>
 	</xsl:template>
 
 
  <!-- Navigation -->
  <xsl:template match="/translation/description/navigation/previous"> 
	<li><a><xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>Zurück: <xsl:value-of select="."/></a></li>
  </xsl:template>
  <xsl:template match="/translation/description/navigation/next"> 
	<li><a><xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>Weiter: <xsl:value-of select="."/></a></li>
  </xsl:template>


<!-- /////////////////////////  Gliederung ///////////////////////// -->
<xsl:template match="translation/structure">
	<xsl:apply-templates select="list"/>
</xsl:template>

<xsl:template match="list">
	<ul class="gliederung">
		<xsl:attribute name="style"><xsl:value-of select="@style"/></xsl:attribute> <!-- erlaube angepassten Stil (z.B. arabisch statt römisch) -->
		<xsl:apply-templates />
	</ul>
</xsl:template>

<xsl:template match="item">
	<li>
		<xsl:attribute name="value"><xsl:value-of select="@value"/></xsl:attribute> <!-- erlaube bei einer definierten Nummer zu starten -->
		<xsl:choose>
			<xsl:when test="@url">
				<a>
					<xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
					<xsl:value-of select="."/>
				</a>
			</xsl:when>
			<xsl:when test="@number">
				<a>
					<xsl:attribute name="href">#anchor<xsl:value-of select="@number"/></xsl:attribute>
					<xsl:value-of select="."/>
				</a>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
		</xsl:choose>
	</li>
</xsl:template>

 
<!-- /////////////////////////  Der eigentliche Text ///////////////////////// -->
  <xsl:template match="translation/text"> 
    <xsl:apply-templates/>      <!-- hier werden die einzelnen Textabschnitte eingefügt -->
    <div class="section"></div> <!-- sorgt für ein abschließendes clear=both -->
  </xsl:template> 
  
  
  <!-- Ein Abschnitt: besteht aus dem Text (lateinisch, deutsch) und dem Kommentar-Bereich --> 
  <xsl:template match="translation/text/section">
  	<!-- speichere die erste Versnummer des Abschnitts -->
  	<xsl:variable name="currnum">
  		<xsl:value-of select="@from" /> 
  	</xsl:variable>
  	
  	<!-- Eventuell Zwischenüberschrift; dazu alle Gliederungs-Einheiten durchgehen und ... -->
  	<xsl:for-each select="/translation/structure/descendant::item">
  		<!-- ... falls die Paragraphen-Nummer mit dem Nummer-Attribut des Gliederungs-Items übereinstimmt,
  		     diese ausgeben (mit Anchor für die Navigation) -->
  		<xsl:if test="@number = $currnum">
  		   	<h3>
			<a style="color: black; text-decoration: none">
	    		<xsl:attribute name="name">anchor<xsl:value-of select="$currnum"/></xsl:attribute>    		
				<xsl:value-of select="."/>
			</a>
			</h3>
 		</xsl:if>
  	</xsl:for-each>
  	
  	<!-- beginne den Abschnitt -->
    <div class="section">
	    <!-- show/showComment-Effekt -->
	    <!-- <xsl:attribute name="onMouseOver">showCommentPreview('<xsl:value-of select="$currnum"/>')</xsl:attribute>
		<xsl:attribute name="onMouseOut">hideCommentPreview('<xsl:value-of select="$currnum"/>')</xsl:attribute> -->
		<xsl:attribute name="id"><xsl:value-of select="$currnum"/>section</xsl:attribute>
		
		<!--<div class="commentbubble">-->
			<!--<xsl:attribute name="onClick">showComments('<xsl:value-of select="$currnum"/>')</xsl:attribute>-->
			<!--<xsl:value-of select="commentcount/@value"/>-->
		<!--</div>-->
		
        <xsl:apply-templates select="german"/> <!-- fügt deutschen Text ein -->
        <xsl:apply-templates select="latin"/> <!-- fügt lateinischen Text ein -->
       	
       	<xsl:apply-templates select="comments"/> <!-- fügt Kommentare ein -->
    </div>
  </xsl:template> 


  <!-- Deutscher Text: Paragraphen-Nummern immer in [] vorne dran -->
  <xsl:template match="translation/text/section/german">
	<p class="german">
		<xsl:variable name="from" select="../@from"/>
		<xsl:variable name="to" select="../@to"/>
		<span class="abschittnummer">
		<xsl:choose>
			<xsl:when test="$from = $to">[<xsl:value-of select="$from" />]</xsl:when>
			<xsl:when test="$from != $to">[<xsl:value-of select="$from" />-<xsl:value-of select="$to" />]</xsl:when>
		</xsl:choose>
		</span>
		<xsl:apply-templates />
    	<!-- <xsl:value-of select="." /> -->
    </p>
  </xsl:template> 

<!-- Innerhalb eines längeren, durchgehenden Übersetzungsabschnitts können Vers/Paragraphen-Nummern eingefügt sein, so dass der Vergleich mit dem lat Original leichter wird  -->
<xsl:template match="translation/text/section/german/para">
	<span class="abschittnummer">[<xsl:value-of select="@no"/>]</span>
</xsl:template>
<xsl:template match="translation/text/section/german/newparagraph">
	<br/>
	<span class="abschittnummer">[<xsl:value-of select="@number"/>]</span>
</xsl:template>


  <!-- Lateinischer Text -->
  <xsl:template match="translation/text/section/latin">
	<p>
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="../german">latin</xsl:when>	<!-- Falls Übersetzung: nur 50% der Breite -->
				<xsl:otherwise>latin_only</xsl:otherwise>	<!-- Sonst: lateinischer Text über die ganze Breite -->
			</xsl:choose>
		</xsl:attribute>
	
		<xsl:variable name="from" select="../@from"/>
		<xsl:variable name="to" select="../@to"/>
		<!-- Falls ein Prosa-Text vorlieg, kommt die Abschnittsnummer in eckigen Klammern an den Anfang des Abschnitts -->
		<xsl:if test="$texttype!='poetry'">
			<span class="abschittnummer">
			<xsl:choose>
				<xsl:when test="$from = $to">[<xsl:value-of select="$from" />]</xsl:when>
				<xsl:when test="$from != $to">[<xsl:value-of select="$from" />-<xsl:value-of select="$to" />]</xsl:when>
			</xsl:choose>
			</span>
		</xsl:if>
		
<!--		<xsl:choose>
			<xsl:when test="$texttype='poetry'"><xsl:apply-templates/></xsl:when>
			<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
		</xsl:choose> -->
		<xsl:apply-templates/>
    </p>
  </xsl:template>

  <!-- erzeugt für peotry-Text Versnummern für den lateinischen Text, anhand der <br/>s -->
  <xsl:template match="translation/text/section/latin/br">
  	<!-- Nummer des ersten Verses aus dem aktuellen Abschnitt -->
  	<xsl:variable name="startnum">
  		<xsl:value-of select="../../@from" /> 
  	</xsl:variable>
  	<!-- Aktuelle Vers-Nummer -->
  	<xsl:variable name="currnum" select="$startnum+(position() div 2)" /> <!-- "div 2" weil die Text-Teile zwischen den BRs anscheinend mitgezählt werden -->
  	
  	<br/>
  	
  	<!-- Falls wir es mit einem Gedicht zu tun haben und
  	     die aktuelle Versnummer ein Vielfaches von 5 ist, schreiben wir sie hin -->
	<xsl:if test="(($currnum mod 5) = 0) and ($texttype = 'poetry')">
		<span class="versnummer"><xsl:value-of select="$currnum" /></span>
	</xsl:if>
  </xsl:template>
  
  <xsl:template match="translation/text/section/latin/newparagraph">
  	<br/>
	<span class="abschittnummer">[<xsl:value-of select="@number"/>]</span>
  </xsl:template>
  
  
<!-- /////////////////////////  Erzeuge Kommentare ///////////////////////// -->
<xsl:template match="translation/text/section/comments">
  	<!-- Anzahl der Kommentare ermitteln -->
  	<xsl:variable name="numcomments" select="comment"/>
  	<!-- id des Abschnitts (entspricht erster Vers/Paragraphennummer) -->
  	<xsl:variable name="startnum" select="../@from"/>

	<div class="comments">
		<xsl:attribute name="id"><xsl:value-of select="$startnum"/>comments</xsl:attribute>
					
		<!-- Liste der Kommentare -->
		<div class="commentList">

			<!-- Schließen-Button -->
			<div class="closeComments">
				<a>
					<xsl:attribute name="href">javascript:hideComments('<xsl:value-of select="$startnum"/>')</xsl:attribute>
					schließen
				</a>
			</div>

			<!-- Die eigentlichen, schon vorhandenen Kommentare -->
			<xsl:for-each select="comment">
				<div class="commentEntry">
					<p class="commentHead"><xsl:value-of select="@name"/> schrieb: <xsl:value-of select="@title"/></p>
					<p class="commentText">
						<xsl:call-template name="nl2br">
                        	<xsl:with-param name="contents" select="./text()" />
						</xsl:call-template>
					</p>
				</div>
			</xsl:for-each>
		
			<!-- Neuen Kommentar hinzufügen -->
			<div class="commentEntry" style="border: 0px;">
				<xsl:attribute name="id"><xsl:value-of select="$startnum"/>newcomment</xsl:attribute>
				
				<p class="commentHead">Neuer Kommentar:</p>
				<p class="commentText">
					<form accept-charset="UTF-8">
					<xsl:attribute name="id"><xsl:value-of select="$startnum"/>form</xsl:attribute>
					
					<input type="hidden" name="siteid">
						<xsl:attribute name="value"><xsl:value-of select="$siteid"/></xsl:attribute>
					</input>
					<input type="hidden" name="section">
						<xsl:attribute name="value"><xsl:value-of select="$startnum"/></xsl:attribute>
					</input>
					
					<table class="newComment">
						<tr>
							<td>Name:</td>
							<td><input name="name" style="width: 50%"/></td>
						</tr>
						<tr>
							<td>Thema:</td>
							<td><input name="title" style="width: 50%"/></td>
						</tr>
						<tr>
							<td>Text:</td>
							<td><textarea name="text" rows="5" style="width: 100%"></textarea></td>
						</tr>
						<tr>
							<td colspan="2">
								<input type="button" class="submit" value="Hinzufügen">
									<xsl:attribute name="onClick">addComment('<xsl:value-of select="$startnum"/>')</xsl:attribute>
								</input>
							</td>
						</tr>
					</table>
					</form>
				</p>
			</div>
		</div> <!-- class="commentList" -->
	</div> <!-- class="comments" -->
</xsl:template>


  
 <xsl:template name="nl2br">
                <xsl:param name="contents" />
                <xsl:choose>
                        <xsl:when test="contains($contents, '&#10;')">
                                <xsl:value-of select="substring-before($contents, '&#10;')" />
                                <br />
                                <xsl:call-template name="nl2br">
                                        <xsl:with-param name="contents" select="substring-after($contents, '&#10;')" />
                                </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select="$contents" />
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
  
</xsl:stylesheet>
