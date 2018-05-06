<?php

require_once('../config.php');

$conn = -1;

# Datenbankverbindung herstellen
function startConnection() {
	global $conn, $server, $user, $passw, $database;
	
	$conn = mysql_pconnect($server.$port, $user, $passw);
	if (!$conn)
		throw new Exception('Keine Datenbank-Verbindung');
	if (!mysql_select_db($database, $conn))
		throw new Exception('Datanbank nicht ausgewählt');
}


# Query ausführen und ResultSet liefern
function getResultArray($query) {
	global $conn;
	
	$res = mysql_query($query, $conn);
	if (!$res)
		throw new Exception("Konnte folgende Abfrage nicht ausführen: " . $query);
	
	$resArr = array();
	while ($row = mysql_fetch_array($res))
		array_push($resArr, $row);
	
	mysql_free_result($res);
	return $resArr;
}


# Query ausühren (für INSERT, DELETE oder UPDATE)
function doQuery($queryStr) {
	global $conn;
	
	$res = mysql_query($queryStr, $conn);
	if (!$res)
		throw new Exception("Konnte folgende Abfrage nicht ausführen: " . $queryStr);
}

# Besorgt die Kommentare-Zähler (!) zur Seite mit der gegebenen id
# Format des Rückgabewertes:
#  array (
#    sectionNumber => numComments,
#	 ...
#  )
function getCommentCount($id) {
	try {
		startConnection();
		$query = "SELECT count(*) as count, section FROM section_notes WHERE siteid = \"$id\" GROUP by section";
		$rows = getResultArray($query);
	}
	catch (Exception $e) {
		print "<div style='color: red'>Ausnahme: Konnte Kommentare nicht laden. (\"" . $e->getMessage() . "\" failed)</div>";
    	return array();
	}
	
	$countBySection = array();
	foreach ($rows as $row) {
		$section = $row["section"];
		$count   = $row["count"];
		$countBySection[$section] = $count;
	}
	return $countBySection;
}


# Besorgt die Kommentare zur Seite mit der gegebenen id
# Das Datenformat des Ergebnisses wird weiter unten beschrieben.
function getComments($id) {
	try {
		startConnection();
		$query = "SELECT * FROM section_notes WHERE siteid = \"" . $id . "\"";
		$comments = getResultArray($query);
	}
	catch (Exception $e) {
		print "<div style='color: red'>Ausnahme: Konnte Kommentare nicht laden. (\"" . $e->getMessage() . "\" failed)</div>";
    	return array();
	}
	
	# Erstelle folgende Datenstruktur:
	#  array (
	#    sectionNumber => array (
	#                       array ( name, title, text ), 
	#                       array ( name, title, text ),
	#                       ...
	#                     ),
	#	 ...
	#  )
	$commentsBySection = array();
	foreach ($comments as $comment) {
		$section = $comment["section"];
		if (!array_key_exists($section, $commentsBySection))
			$commentsBySection[$section] = array();
		
		$name = $comment["name"];
		$date = $comment["date"];
		$title = $comment["title"];
		$text = $comment["text"];
		
		array_push($commentsBySection[$section], array( "name" => $name, "date" => $date, "title" => $title, "text" => $text )); 
	}
	return $commentsBySection;
}

# Das große ganze: Übergebenes XML-File laden, mit Kommentaren anreichern,
# XSLT-Transformation ausführen und schließlich Ergebnis schreiben.
function processXML($dataFile, $xslFile = "translation.xsl") {
	$path = dirname(__FILE__) . '/'; 

	# Prüfen, ob die angeforderte Seite schon im Cache liegt und ggf ausgeben
	$cache_file = str_replace("/", "_", $dataFile);
	$cache_file = $path . 'cache/' . $cache_file;
//	if (file_exists($cache_file)) {
	if (false) {
		readfile($cache_file);
		return;
	}
	# an dieser Stelle wissen wir: nicht gecacht, daher erzeugen

	# XSLT Stylesheet als "normales" XML-DOM Dokument laden 
	$xslDom = new domdocument; 
	$xslDom->load($path . $xslFile);
	
	# XML-Daten laden 
	$xmlDom = new domdocument; 
	$xmlDom->load($path . $dataFile); 
	
	# nun f.j. Abschnitt die Kommentare besorgen (der (relative) Pfad des Dokuments ist die Site-ID für die Kommentar-Tabelle)
#	$commentCountBySection = getCommentCount($dataFile);
	$commentsBySection = getComments($dataFile);
	
	# im DOM-Baum alle <section>s durchgehen und die Kommentar-Zahl als neue Kinder hinzufügen. So sieht das dann aus:
	# <section>
	#	<commentcount> 42 </commentcount>
	#   <german> blub </german>
	#   <lating> bla </latin>
	#   <comments>
	#     <comment name="markus" date="wann" title="test-kommentar">
	#        Hier steht der Text des Kommentars
	#     </comment>
	#     <comment name="mari" date="morgen" title="hallo">
	#        ich wollte auch noch was sagen.
	#     </comment>
	#   </comments>
	# </section>
	$domSections = $xmlDom->getElementsByTagName("section");
	foreach ($domSections as $domSection) {
		$sectionNumber = $domSection->getAttribute("from");
		$comments      = $commentsBySection[$sectionNumber];
#		$commentCount  = $commentCountBySection[$sectionNumber];
		$commentCount = (is_array($comments)) ? count($comments) : 0;
		
		# Anzahl Kommentare einfügen
		$domCommentCount = $xmlDom->createElement("commentcount");
		$domCommentCount->setAttribute("value", $commentCount);
		$domSection->appendChild($domCommentCount);
		
		# Kommentare selbst einfügen
		$domComments = $xmlDom->createElement("comments");
		$domSection->appendChild($domComments);

		if ($commentCount == 0)
			continue;
	
		foreach ($comments as $comment) {
			$domComment = $xmlDom->createElement("comment");
			$domComment->setAttribute("name", $comment["name"]);
			$domComment->setAttribute("title", $comment["title"]);
			$domComment->setAttribute("date", $comment["date"]);
			$domComment->appendChild($xmlDom->createTextNode($comment["text"]));
			$domComments->appendChild($domComment);
		}
	}
	
	# außerdem fügen wir noch die SiteID in den DOM-Tree ein (den braucht das JS-Script
	# für's Einfügen neuer Kommentare)
	$domID = $xmlDom->createElement("siteid");
	$domID->appendChild($xmlDom->createTextNode($dataFile));	# (relativer) Pfad ist die ID!
	$xmlDom->appendChild($domID);
	
	# Jetzt die Transformation durchführen
	$xsl = new XsltProcessor; // XSLT Prozessor Objekt erzeugen 
	$xsl->importStylesheet($xslDom); // Stylesheet laden 
	$result = $xsl->transformToXML($xmlDom); // Transformation - return XHTML 
	
	# Ergebnis cachen und ausgeben
	file_put_contents($cache_file, $result, LOCK_EX);
	echo $result;
}


# Fügt neuen Kommentar ein.
function addComment($id, $section, $name, $title, $text) {
	startConnection();
	$id = mysql_real_escape_string($id);
	$section = mysql_real_escape_string($section);
	$name = mysql_real_escape_string($name);
	$title = mysql_real_escape_string($title);
	$text = mysql_real_escape_string($text);
	

	$query = "INSERT INTO section_notes (siteid, section, name, title, text, date) VALUES ('$id', '$section', '$name', '$title', '$text', NOW())";
	
	doQuery($query); # wenn was schiefgeht, wirft doQuery eine Exception, die wir hier nicht abfangen...
	
	# Wir haben einen Kommentar hinzugefügt, die Seite also geändert; deswegen
	# müssen wir sie außerdem aus dem Cache löschen.
	$id = str_replace("/", "_", $id);	# beachte: SiteID war der Pfad zum XML-File mit dem Inhalt
	$cache_file = dirname(__FILE__) . '/cache/' . $id;
	# die obigen zwei Zeilen sollten außerdem sicherstellen, dass uns niemand etwas ala
	# "../../../passwd" zum Löschen unterschiebt, oder?
	
	if (file_exists($cache_file)) {
		if (!unlink($cache_file))
			throw new Exception("Cache-Datei konnte nicht gelöscht werden - Ihr Kommentar wird vermutlich nicht erscheinen, ist aber gesichert. Bitte kontaktieren Sie markus@romanum.de - Danke.");
	}
}

?>