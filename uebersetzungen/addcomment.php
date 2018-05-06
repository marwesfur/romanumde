<?
	require_once("functions.php");
	
	try {
		$id = $_GET["siteid"];
		$section = $_GET["section"];
		$name = $_GET["name"];
		$title = $_GET["title"];
		$text = $_GET["text"];

		addComment($id, $section, $name, $title, $text);
		
#############################
#   Frage: Warum ersetzten wir in $text nicht die "\n"s durch <br>s bevor wir den Eintrag in die DB machen?
# Antwort: das scheint irgendwelche Probleme mit der XSL-Transformation zu machen - jedenfalls kommt am Ende immer ein &lt;br/&gt; raus
#          ich weiß nicht wie ich das beheben könnte...
#          Deshalb: Mit den Newlines in der DB speichern und erst ganz am Ende bei der XSL-Transformation die Newlines in <br>s umwandeln.
#          Das übernimmt übrigens das Template "nl2br"
#############################

		?>
			<p class="commentHead">Sie schrieben gerade: <?= $title ?></p>
			<p class="commentText"><?= str_replace("\n", "<br/>", $text)?></p>
		<?php
	}
	catch (Exception $e) {
		print "<div style='color: red'>Ausnahme: Konnte Kommentar nicht hinzufügen (\"" . $e->getMessage() . "\")</div>";
	}
?>

