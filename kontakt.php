<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Romanum - Kontakt und Feedback</title>
	<link rel="stylesheet" type="text/css" href="base.css"/>
</head>
<body>
	

<div id="container">
	<div id="pageHeader">
		<div id="navigation">
			<ul>
				<li class="welcome"><a title="" href="index.html">Startseite</a></li>
				<li class="translation"><a title="" href="uebersetzungen/index.html">Übersetzungen</a></li>
				<li class="contact on"><a title="" href="kontakt.php">Kontakt</a></li>
				<li class="impressum"><a title="" href="impressum.html">Impressum</a></li>
				<li class="datenschutz"><a title="" href="datenschutz.html">Datenschutz</a></li>
			</ul>
		</div>
		<a href="index.html"><h1 id="title">Romanum</h1></a>
	</div>
	<div id="contents">

		
<?php
	if (isset($_POST["author"])) {
        $text = "";
        $text .= "Name:  " . $_POST["author"] ."\n";
        $text .= "Email: " . $_POST["email"] . "\n\n";
        $text .= "Kommentar:\n" . $_POST["comment"] . "\n\n\n";
        
        $headers = "From: " . $_POST["email"] . "\n";
        $headers .= "Content-Type: text/plain; charset=UTF-8 \n";
        
        mail("mail@markuswestphal.de", "Kontakt-Formular auf romanum.de", $text, $headers);
?>

		<h2>Vielen Dank!</h2>
		<p>Wir werden Ihre Nachricht schnellstmöglich beantworten und Sie per Email kontaktieren. Hier nochmals Ihre Angaben:</p>
		<table class="contact">
			<tr>
				<td class="nobreak">Ihr Name:</td>
				<td><? echo $_POST["author"]; ?> (<? echo $_POST["email"]; ?>)</td>
			</tr>
			<tr>
				<td class="nobreak">Ihr Text:</td>
				<td><? echo str_replace("\n","<br/>",$_POST["comment"]); ?></td>
			</tr>
		</table>
		<p>&nbsp;<br/><a href="kontakt.php">Zurück zum Formular</a></p>
<?
	}
	else {
?>
		<div class="infobox">
			<div class="top"></div>
			<div class="main">
				<p><b>Bitte beachten Sie:</b><br/> Wir können Ihnen leider keinen Übersetzungsservice anbieten,
				da uns hierfür einfach die Ressourcen fehlen - wir hoffen auf Ihr Verständnis und bitten von derartigen Anfragen abzusehen.</p>
			</div>
			<div class="bottom"></div>
		</div>
			

		<h2>Kontaktformular</h2>
		<p>Wollen Sie gerne eine eigene Übersetzung auf romanum.de veröffentlichen? Oder haben Sie einen Fehler in einer unserer Übersetzungen gefunden?
		Wir freuen uns natürlich aber auch über jeden anderen Kommentar, der uns erreicht...</p>
		<p>Sie können entweder direkt per Email mit uns in Kontakt treten (die Adresse lautet: <a href="mailto:markus@romanum.de">markus@romanum.de</a>)
		oder das Formular am Ende dieser Seite benutzen.</p>
		
<script language="javascript" type="text/javascript">
	/**
	 * DHTML email validation script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
	 */
	function echeck(str) {
		var at="@"
		var dot="."
		var lat=str.indexOf(at)
		var lstr=str.length
		var ldot=str.indexOf(dot)
		if (str.indexOf(at)==-1){
		   return false
		}

		if (str.indexOf(at)==-1 || str.indexOf(at)==0 || str.indexOf(at)==lstr){
		   return false
		}

		if (str.indexOf(dot)==-1 || str.indexOf(dot)==0 || str.indexOf(dot)==lstr){
		    return false
		}

		 if (str.indexOf(at,(lat+1))!=-1){
		    return false
		 }

		 if (str.substring(lat-1,lat)==dot || str.substring(lat+1,lat+2)==dot){
		    return false
		 }

		 if (str.indexOf(dot,(lat+2))==-1){
		    return false
		 }
		
		 if (str.indexOf(" ")!=-1){
		    return false
		 }

 		 return true					
	}

	function validateForm() {
		var ok = true;
		var errMsg = "";
		var mailID = document.forms[0].email;
	
		if ((mailID.value == null) || (mailID.value == "") ||  (echeck(mailID.value) == false)) {
			errMsg += "Bitte überprüfen Sie Ihre Email-Adresse.\n";
			ok = false;
			document.forms[0].email.focus();
		}
		if (document.forms[0].author.value.length == 0) {
			errMsg += "Bitte geben Sie Ihren Namen ein.\n";
			ok = false;
			document.forms[0].author.focus();
		}
		if (!ok) {
			alert(errMsg);
			return false;
		}
		
		return true;
	}
</script>

 
		<form action="kontakt.php" method="post" accept-charset="UTF-8" id="contactform" onsubmit="return validateForm()">
		<table class="contact">
			<tr>
				<td class="nobreak"><label for="author">Ihr Name:</label></td>
				<td><input class="long" type="text" name="author" id="author" value="" size="22" tabindex="1" /></td>
			</tr>
			<tr>
				<td class="nobreak"><label for="email">Email-Adresse:</label></td>
				<td><input class="long" type="text" name="email" id="email" value="" size="22" tabindex="2" /></td>
			</tr>
			<tr>
				<td class="nobreak"><label for="comment">Ihre Nachricht:</label></td>
				<td><textarea name="comment" id="comment" cols="100%" rows="10" tabindex="3"></textarea></p></td>
			</tr>
			<tr>
				<td></td>
				<td><input type="submit" id="submit" tabindex="4" value="Senden" /></td>
			</tr>
		</table>
		</form>
		<p>Vielen Dank - wir freuen uns schon auf Ihre Nachricht!</p>
<?
	}		
?>
		
	</div>
	
	<div id="footer">
	</div>
</div>


</body>
</html>
