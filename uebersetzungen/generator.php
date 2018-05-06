<?php
# Achtung: diese Datei am besten auf dem Server von Hand anlegen, also mit:
#   touch generator.php
#   vim generator.php
# und dann den Inhalt von Hand hinschreiben.
# Anscheinend gibt es Probleme mit der Uebertragung: Es schleichen sich vor dem "<?php"
# noch ein paar Bits ein, die dann dazu fuehren, dass im IE 6 der Quirks-Mode aktiviert wird...


header("Last-Modified: " . gmdate("D, d M Y H:i:s", time() - 24*60*60) . " GMT");
header("Content-Type: text/html");


require_once('functions.php');

# Aus uebergebenem Parameter ("file") darzustellende XML-Datei ermitteln
$file = $_GET["file"];
$file = $file . ".xml";


processXML($file, "translation.xsl");

?>