<?xml version="1.0" encoding="utf-8"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"> 
 
  <xsl:output method="xml"  
    version="1.0"  
    indent="yes"  
    encoding="utf-8"  
    media-type="text/xml"  
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    omit-xml-declaration="yes"/>  <!-- ohne das würde der IE6 in den Quirks-Mode wechseln. -->
 
 
<!-- /////////////////////////  Variablen ///////////////////////// -->
	<!-- Art des Textes (poetry, prose) -->
 	<xsl:variable name="texttype" select="/translation/description/textkind" />

	<!-- SiteID (für's Erstellen von Kommentaren) -->
	<xsl:variable name="siteid" select="/siteid" />



<!-- /////////////////////////  Seitenumfeld ///////////////////////// -->
 	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
			<title>
				<xsl:value-of select="/translation/description/author"/>: <xsl:value-of select="/translation/description/title"/> (<xsl:value-of select="/translation/description/snippet"/>)
			</title>
			<link rel="stylesheet" type="text/css" href="../../../print.css"/>
		</head>
		<body>
		
		<div id="header">
			<h2 id="author"><xsl:value-of select="/translation/description/author"/></h2>
			<h1 id="title"><xsl:value-of select="/translation/description/title"/></h1>
			<h1 id="snippet"><xsl:value-of select="/translation/description/snippet"/></h1>
			<h3 id="translator">Übersetzt von <xsl:value-of select="/translation/description/translator"/></h3>
		</div>
		<div id="contents">
			<!-- Gliederung -->
			<xsl:apply-templates select="translation/structure" />
				
			<!-- Hier nun der eigentliche Inhalt (Text) -->
			<xsl:apply-templates select="translation/text"/>
		</div>
		
		</body>
		</html>
 	</xsl:template>


<!-- /////////////////////////  Gliederung ///////////////////////// -->
	<xsl:template match="translation/structure">
		<xsl:apply-templates select="list"/>
	</xsl:template>

	<xsl:template match="list">
		<ul class="gliederung">
			<xsl:apply-templates />
		</ul>
	</xsl:template>

	<xsl:template match="item">
		<li><xsl:value-of select="."/></li>
	</xsl:template>

 
<!-- /////////////////////////  Der eigentliche Text ///////////////////////// -->
	<xsl:template match="translation/text"> 
		<xsl:apply-templates/>
	</xsl:template> 
  
  
	<!-- Ein Abschnitt: besteht aus Zwischenüberschriften und dem eigentlichen Text in Latein und (ggf) Deutsch --> 
	<xsl:template match="translation/text/section">
		<!-- speichere die erste Versnummer des Abschnitts -->
		<xsl:variable name="currnum"><xsl:value-of select="@from" /></xsl:variable>
  	
		<!-- Eventuell Zwischenüberschrift anzeigen; dazu alle Gliederungs-Einheiten durchgehen und ... -->
		<xsl:for-each select="/translation/structure/descendant::item">
			<!-- ... falls die Paragraphen-Nummer mit dem Nummer-Attribut des Gliederungs-Items übereinstimmt,
			      diese ausgeben (mit Anchor für die Navigation) -->
			<xsl:if test="@number = $currnum">
				<h3 class="internalheading"><xsl:value-of select="."/></h3>
			</xsl:if>
		</xsl:for-each>
  	
		<!-- beginne den Abschnitt -->
		<div class="section">
      		<xsl:apply-templates select="german"/> <!-- fügt deutschen Text ein -->
			<xsl:apply-templates select="latin"/> <!-- fügt lateinischen Text ein -->
		</div>
	</xsl:template> 


	<!-- Deutscher Text: Paragraphen-Nummern immer in [] vorne dran -->
	<xsl:template match="translation/text/section/german">
		<xsl:variable name="from" select="../@from"/>
		<xsl:variable name="to" select="../@to"/>

		<p class="german">
			<span class="abschittnummer">
				<xsl:choose>
					<xsl:when test="$from = $to">[<xsl:value-of select="$from" />]</xsl:when>
					<xsl:when test="$from != $to">[<xsl:value-of select="$from" />-<xsl:value-of select="$to" />]</xsl:when>
				</xsl:choose>
			</span>
			<xsl:apply-templates /> <!-- nur noch CDATA bzw. <para>-Tags (s.u.) -->
		</p>
	</xsl:template> 

	<!-- Innerhalb eines längeren, durchgehenden Übersetzungsabschnitts können Vers/Paragraphen-Nummern
	     eingefügt sein, so dass der Vergleich mit dem lateinischen Original leichter wird  -->
	<xsl:template match="translation/text/section/german/para">
		<span class="abschittnummer">[<xsl:value-of select="@no"/>]</span>
	</xsl:template>


	<!-- Lateinischer Text -->
	<xsl:template match="translation/text/section/latin">
		<xsl:variable name="from" select="../@from"/>
		<xsl:variable name="to" select="../@to"/>

		<p>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="../german">latin</xsl:when>	<!-- Falls Übersetzung: nur 50% der Breite -->
					<xsl:otherwise>latin_only</xsl:otherwise>	<!-- Sonst: lateinischer Text über die ganze Breite -->
				</xsl:choose>
			</xsl:attribute>
	
			<!-- Falls ein Prosa-Text vorliegt, kommt die Abschnittsnummer in eckigen Klammern
			     an den Anfang des Abschnitts -->
			<xsl:if test="$texttype!='poetry'">
				<span class="abschittnummer">
					<xsl:choose>
						<xsl:when test="$from = $to">[<xsl:value-of select="$from" />]</xsl:when>
						<xsl:when test="$from != $to">[<xsl:value-of select="$from" />-<xsl:value-of select="$to" />]</xsl:when>
					</xsl:choose>
				</span>
			</xsl:if>
		
			<xsl:apply-templates/> <!-- CDATA und <br>-Tags im Falle von Lyrik (Versnummern einfügen!) -->
		</p>
	</xsl:template>

	<!-- erzeugt für Lyrik-Texte Versnummern für den lateinischen Text anhand der <br>-Tags -->
	<xsl:template match="translation/text/section/latin/br">
		<!-- Nummer des ersten Verses aus dem aktuellen Abschnitt -->
		<xsl:variable name="startnum"><xsl:value-of select="../../@from" /></xsl:variable>
		<!-- Aktuelle Vers-Nummer aus Startnummer und der Position des <br>-Tags berechnen -->
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
  
</xsl:stylesheet>