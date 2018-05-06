	// from http://blog.josh420.com/archives/2007/10/centering-an-element-on-the-page-with-javascript-cross-browser.aspx
	function getViewportDimensions() {
	    var intH = 0, intW = 0;

	    if(self.innerHeight) {
	       intH = window.innerHeight;
	       intW = window.innerWidth;
	    } 
	    else {
	        if(document.documentElement && document.documentElement.clientHeight) {
	            intH = document.documentElement.clientHeight;
	            intW = document.documentElement.clientWidth;
	        }
	        else {
	            if(document.body) {
	                intH = document.body.clientHeight;
	                intW = document.body.clientWidth;
	            }
	        }
	    }

	    return {
	        height: parseInt(intH, 10),
	        width: parseInt(intW, 10)
	    };
	}
	
	function animatedScroll (targetY) {
		// Wo sind wir gerade?
		if (window.pageYOffset) { // Mozilla, Opera, WebKit
		    currY = window.pageYOffset;
		} else if (document.body && document.body.scrollTop) {	// IE
		    currY = document.body.scrollTop;
		}
		else
			return scrollTo(0, targetY); // das sollte eigentlich nicht vorkommen!
	
		// Ziel erreicht
		if (currY > targetY)
			return;
	
		// bei jedem Schritt wird der Abstand zum Ziel um ein drittel (oder wenigstens 30px) verkürzt -> am anfang schnelle, am ende langsame bewegung
		diff = (targetY - currY)/3;
		if (diff < 30)
			diff = 30;
	
		scrollBy(0, diff);
		setTimeout("animatedScroll(" + targetY + ")", 10);
	}


	function showComments(which) {
		// Anzeigen
		$(which + "comments").style.display = 'block';

		// Position Oberkante des Kommentarbereichs
		commY = $(which + "comments").offsetTop;
		
		// Größe des Fensters
		height = getViewportDimensions().height;
		
		// Berechne Scroll-Ziel
		howMuchVisible = 255; // wieviel vom Kommentar-Bereich soll sichtbar sein
		targetY = commY-height+howMuchVisible;	// Oberkante des Kommentarbereichs ist <howMuchVisible>px oberhalb des unteren Fensterrandes

		// Starte animiertes Scrollen zum Ziel
		animatedScroll(targetY)
	}
		
	function hideComments(which) {
		$(which + "comments").style.display = 'none';
	}
	
	function addComment(id) {
		form = id + "form";
		id = id + "newcomment";
		
		new Ajax.Updater(id, "../../addcomment.php", {
		  method: 'get',
		  parameters: $(form).serialize(true)
		});
	}
