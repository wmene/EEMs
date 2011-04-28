var token = window._token;
var content_file_id;
var timeoutId = 0;
var delayedJobTimeout = 0;
var data = "ABBASI ABBOTT ABERCROMB ABRAHAMSW ACKERMANR AFRICA AFRICADOC AHNE ANTHRO AREASTREF ARONSONB ARSGIFT ARTARCH ASHENR ASUL ASULMEM ASULRES AVERYC BACKERM BACONR BAILEYT BALDRIDGE BALLARDE BANDETH BARCHASS BARKSDALE BARNESJ BARONJ BELLD BENDERA BENDERRM BENNETT BERNSTEIN BIOLOGY BIOLOGY2 BOOKEXCH BOYLESE BRANGIFT BRASCHF BREERC BRICKERF BROOKSC BRUSHIST BRUSHISTI BRUSLIT BRUSLITI BURDJ BURNELLG BURROWSD CAFAROC CAGLEA CAMPBELLR CANFIELDD CARNOCHAN CELEBFUND CHAMBERLA CHEM CHEMGIFT CHICANO CHINAHV CHINART CHINEXCHG CHJPDOC CHUCKF CLASS1965 CLASS1970 CLASSICS CLEBSCH CLEBSCHW CLEMENTM COCHRANS COFFINJ COHNA COMM COMPRACEC CONNOLLYG COTRELLE CRAIGW CRARYG CROWL CULTSTUD CUSICKJ DATAFILE DATAFILE2 DAVESD DAVISJ DENNINGR DIGICORP DINSMOREM DIROFF DOBBSMELT DONNELLD DUPSOLD DUTTONR EALJAPAN EALMOORE EARTHSCI EARTHSCIM EASTASIA EASTASTVI EBOOKS ECON EDGRENR EDUC EEURDOC EGGERE ELIOTM ENG ENGGIFT ENVIROPOP ESBENSHAD FALCONERF FEHRENBAC FELTONC FEMINIST FIELD FILMPERF FITGERWIL FITZHUGHW FLAHERTYM FORDJ FORDOC FORLANGI FOXS FRANKENST FRANKLHUM FRIENDE FRITDOC FRYBERGER GALLAGHER GALTCOBL GAYLES GEBALLET GENACQ GENGIFT GENREF GENSER GERMANIC GIFTSPPRO GOLDMANR GOLDSTEIN GOODANB GORDONA GOVINFOI GREENC GREENW GROMMONA GUNSTM GWAUDOC HADERLIEE HAEFNERJ HAMMONDA HANNA HANNAP HARRASSOW HARRISJ HARRISL HAUGH HAWES HAYFER HEARST HENMULLER HERRICK HERTLEINL HERTLEINM HESS HILLMAN HIRSCHMAN HISTSCI HMSHO HOBSON HOPKINS HORTON HOWELL1 HOWELL2 HUMINST HUMREF HVACQ INFOACC INFOACCDS INSTSOFTW INTLDOC JACKMANC JACKMAND JACOBSONM JAGELS JAPANHV JAY JEWELFUND JEWISH JOHNSONJ JOHNSONW JONESR JONESW JORDAN KARLE KATSEV KATZEVA KATZEVS KAY KAYSTEEVE KEMBLE KENNEDY KIBLER KIM KIMBALL KITTLE KLEINH KLEINM KLINEROET KNAPPI KNAPPJ KOOPERMAN KOREAN KORFDNGR KUMM KUMMA KUMMFF KUMMFG KUMMH KUMMM KUMMS KWOKB KWOKL LANEWEST LANZ LATAM LATAMIDOC LEITER LEWIS LINDER LINGUIST LIS LITFRANKL LITTAUER LITTPOET LMBSP LOWENTHAL LYMAN LYMANAWAR LYNCH MAHARAM MARKUS MARTINEAU MASON MATHCOMP MCCAMENT MCCULLOUG MCDOWELL MEDIAACQ MEDIAINST MEDIARES MEDIEVAL MEMFUND MEYERBORE MEYERRES MEYERRES2 MGATES MIDEAST MILNE MIRRIELEE MIZOTA MONOORD MORGAN MORRISON MOSER MOULTON MUFFLEY MULLERMCC MUNGER MUNRO MUSIC MUSICARS MUSICSCO MUSICSOU MYERS NIELSEN NISHINO NOFUND NUGGETS OBERLIN OFFEN PAGE PAYNEB PAYNER PECK PERFARTS PERRETTE PERRY PETERSONG PHILBRICK PHILOSOPH PHYSGIFT PHYSICS POLISCI PORTWOOD POYET PRICE PROTHRO PSYCH QUILLEN RASMUSSEN REHNBORGC REHNBORGJ REINERT RELIGION RESEVAL RESMAT RESMATBK RESMATCEN RESMATEND RESMATNEY RESMATOPP RITTER RIXON ROBUSTELL ROMANCE ROSE ROSENBAUM ROSENBERG ROSENBLAT ROSS RUEEUR SAMSON SASIA SASIABUDD SCHIRESON SCITECHI SEASIAPAC SHAFTEL SHARP SHARPS SHAVER SHELDON SHOUP SIEVERS SILIGENE SIMPSON SKINNER SMALL SMORTCHEV SNEDDEN SOARES SOC SOCSCII SOCSCIREF SOWERS SPAPOR SPEC SPECGIFT STAFFREF STANDISH STARLING STATEDOC STEEL STEINBERG STEINMETZ STEVENS STRUBLE SUNDERMEY TANENBAUM TANNERMEM TANNERREL TARBELL TAXACCREV THOMASC THOMASR THOMPSONP THOMPSONW THORPE TIERNAN UARCH UARCHGIFT UKCANDOC ULIBRES USDOC VANWYCK VICKERS1 VICKERS2 VONSCHLE WALLER WARREN WATT WEBB WEBSTER WEISS WEURSOC WEYBURN WHITEHEAD WICKERSHA WIEL WIGGINS WILSON WOOD WOODBURN WOODYATT WREDENB WYATT YOUNGH YOUNGHMAP ZALK ZENOFF".split(" ");
var allowedFileTypes = "pdf doc docx xls xlsx ppt ppts txt";
var defaultValues = {
  note: "(Citation, comments, copyright notes, etc.)",
  payment_fund: "(Fund name)"
};
var dateFormatMask = "yyyy-mm-dd'T'HH:MM:sso";
var msgInvalidFileType = "File to upload is of invalid type.\n Allowed file types are - \n.pdf, .doc, .docx, .xls, .xlsx, .ppt, .ppts, .txt";

$(document).ready(function() {
  // payment fund 	
  $('#eem_bw_payment_fund')
  .autocomplete(data)
  .change(function() { toggleSendToTechServices('#eems-browser-widget'); })
  .focus(function() {
    if ($('#eem_bw_payment_fund').val() == defaultValues.payment_fund) {
	    $('#eem_bw_payment_fund').val('');
     }
   });

  $('#eem_dw_payment_fund')
  .autocomplete(data)
  .change(function() { toggleSendToTechServices('#eems-desktop-widget'); })
  .focus(function() {
    if ($('#eem_dw_payment_fund').val() == defaultValues.payment_fund) {
	    $('#eem_dw_payment_fund').val('');
     }
   });

  // payment type
  $('#eem_bw_paymentType').change(function() {	
		if ($('#eem_bw_paymentType').val() == 'Paid') { $('#eem_bw_payment_fund').show();	}
		else { $('#eem_bw_payment_fund').hide(); }
	

		toggleSendToTechServices('eems-browser-widget');
  });

  $('#eem_dw_paymentType').change(function() {	
		if ($('#eem_dw_paymentType').val() == 'Paid') { $('#eem_dw_payment_fund').show();	}
		else { $('#eem_dw_payment_fund').hide(); }
	
		toggleSendToTechServices('eems-browser-widget');
  });

  // note
  $('#eem_bw_note').focus(function() {
    if ($('#eem_bw_note').val() == defaultValues.note) {
		  $('#eem_bw_note').val('');
    }
  });

  $('#eem_dw_note').focus(function() {
    if ($('#eem_dw_note').val() == defaultValues.note) {
		  $('#eem_dw_note').val('');
    }
  });

  // title
  $('#eem_bw_title').change(function() {
    toggleSaveToDashboard('eems-browser-widget');
    toggleSendToTechServices('eems-browser-widget');
  });

  $('#eem_dw_title').change(function() {
    toggleSaveToDashboard('eems-desktop-widget');
    toggleSendToTechServices('eems-desktop-widget');
  });

  // contentURL (for browser widget)
  $('#contentUrl')
  .hover(function() {
    toggleSaveToDashboard('eems-browser-widget');
    toggleSendToTechServices('eems-browser-widget');
  })
  .change(function() {
    toggleSaveToDashboard('eems-browser-widget');
    toggleSendToTechServices('eems-browser-widget');
  });

  // content_upload (for desktop widget)
  $('#content_upload').change(function() {
    toggleSaveToDashboard('eems-desktop-widget');
    toggleSendToTechServices('eems-desktop-widget');
  });

  // copyright status
  $('#eem_bw_copyrightStatus').change(function() {
    toggleSendToTechServices('eems-browser-widget');
  });

  $('#eem_dw_copyrightStatus').change(function() {
    toggleSendToTechServices('eems-desktop-widget');
  });

  // payment fund
  $('#eem_bw_payment_fund').change(function() {
    toggleSaveToDashboard('eems-browser-widget');
    toggleSendToTechServices('eems-browser-widget');
  });

  $('#eem_dw_payment_fund').change(function() {
    toggleSaveToDashboard('eems-desktop-widget');
    toggleSendToTechServices('eems-desktop-widget');
  });

  // save to dashboard - browser widget
  $('#eem_bw_save_to_dashboard').click(function() {
	  var selectorName = $('#eem_selectorName').val();
    var logMsg = 'Request created by ' + selectorName;
    var pars = 'eem[status]=Created'; 
    submitEEM(pars, logMsg);
  });

  // send to tech services - browser widget
  $('#eem_bw_send_to_tech_services').click(function() {
	  var selectorName = $('#eem_selectorName').val();
    var logMsg = 'Request submitted by ' + selectorName;
    //var pars = 'eem[requestDatetime]=' + dateFormat(dateFormatMask);
    var pars;
    submitEEM(pars, logMsg);
  });

  // save to dashboard - desktop widget
  $('#eem_dw_save_to_dashboard').click(function() {
	  var selectorName = $('#eem_selectorName').val();
    var logMsg = 'Request created by ' + selectorName;
    var pars = 'eem[status]=Created'; 
    submitEEMDesktopUpload(pars, logMsg);
  });

  // send to tech services - desktop widget
  $('#eem_dw_send_to_tech_services').click(function() {
	  var selectorName = $('#eem_selectorName').val();
    var logMsg = 'Request submitted by ' + selectorName;
    var pars = 'eem[requestDatetime]=' + dateFormat(dateFormatMask);
    submitEEMDesktopUpload(pars, logMsg);
  });

});

// submit EEM object (desktop upload)
function submitEEMDesktopUpload(pars, logMsg) {
  var selectorName = $('#eem_selectorName').val();

	var options = {
    target: '#upload_target',
    timeout: 180000,
    beforeSubmit: function() {
	    $('#eems-desktop-widget').fadeOut('slow');
	    $('#eems-loader').show();	 
	
		  if ($('#eem_dw_note').val() == defaultValues.note) { $('#eem_dw_note').val(''); }
		  if ($('#eem_dw_payment_fund').val() == defaultValues.payment_fund) { $('#eem_dw_payment_fund').val(''); }
		
		  $('#eem_dw_statusDatetime').val(dateFormat(dateFormatMask));
		  $('#eem_dw_copyrightStatusDate').val(dateFormat(dateFormatMask));
		  $('#eem_dw_requestDatetime').val(dateFormat(dateFormatMask));		
    }, 
    success: function(data) { 
	    var data = stripHTMLTags(data);
	    var eem_pid = data.replace(/^eem_pid=/, '');

	    if (eem_pid != null && eem_pid != undefined && (/^druid:\w{11}/.test(eem_pid))) {
			  window._pid = eem_pid;  
		    $('#eems-loader').hide();		    
			  $('#details-link').attr('href', '/view/' + trimmedId(eem_pid));				
		    $('#eems-success').show();						
			  $('#eems-links').show();
			
	      // if 'Send to Technical Services' button is pressed 
	      if (/Request submitted by/.test(logMsg)) {
	        sendToTechServices(eem_pid);
	      } 
	    }	
	    else {
			  showPDFErrorMsg(); 	
			}									 		
	  },
	  error: function() { showEEMsErrorMsg(); }		
  };

  $('#eems-desktop-widget').target = 'upload_target';

  if (isValidFileType($('#content_upload').val())) {
	  $('#eems-desktop-widget').ajaxSubmit(options);	
  }
  else {
	  alert(msgInvalidFileType);
  }

  return false;
  
}

// submit EEM object (browser upload)	
function submitEEM(pars, logMsg) { 
  pars = pars + '&eem[statusDatetime]=' + dateFormat(dateFormatMask);
  pars = pars + '&eem[copyrightStatusDate]=' + dateFormat(dateFormatMask);

  if ($('#eem_bw_note').val() == defaultValues.note) { $('#eem_bw_note').val(''); }
  if ($('#eem_bw_payment_fund').val() == defaultValues.payment_fund) { $('#eem_bw_payment_fund').val(''); }

  var eem_data = $('#eems-browser-widget').serialize() + '&' + pars;

  if ($('#contentUrl').val() == '') {
	  showLoader();	
    createEEM_WithoutPDF(eem_data, logMsg);
  } 
  else {
	  if (isValidFileType($('#contentUrl').val())) {
		  showLoader();
	    createEEM_WithPDF(eem_data, logMsg);		
	  } 
	  else {
		  alert(msgInvalidFileType);
	  }
	}

	return false;
 }

// create EEM with PDF
function createEEM_WithPDF(eem_data, logMsg) {
  $.ajax({
	  url: '/eems', 
	  type: 'POST', 
	  datatype: 'json', 
	  timeout: 10000, 
	  data: eem_data, 	  
	  success: function(eem) {			
	    $('#eems-loader').hide();
			$('#eems-upload-progress').show();	  
		  				
			if (eem != null && eem.eem_pid != null && (/^druid:\w{11}/.test(eem.eem_pid))) {
				window._pid = eem.eem_pid;  
			  
		    var selectorName = $('#eem_selectorName').val();

			  $('#details-link').attr('href', '/view/' + trimmedId(eem.eem_pid));	
	      content_file_id = eem.content_file_id;		

		    update();
		
	      // if 'Send to Technical Services' button is pressed 
	      if (/Request submitted by/.test(logMsg) && eem.content_file_id != undefined) {
	        sendToTechServices(eem.eem_pid);
	      } 			
			} 
			else {
			  showPDFErrorMsg(); 	
			}					
	  }, 
	  error: function() { showEEMsErrorMsg(); },  			
	});  
}

// create EEM without a PDF
function createEEM_WithoutPDF(eem_data, logMsg) {
  $.ajax({
	  url: '/eems/no_pdf', 
	  type: 'POST', 
	  datatype: 'json', 
	  timeout: 10000, 
	  data: eem_data, 
	  success: function(eem) {			
			if (eem != null && eem.eem_pid != null && (/^druid:\w{11}/.test(eem.eem_pid))) {				
			  $('#details-link').attr('href', '/view/' + trimmedId(eem.eem_pid));	
		    $('#eems-loader').hide();	
		    $('#eems-success').show();			
		    $('#eems-links').show();							  
			} 
	  },
		error: function() { showEEMsErrorMsg(); },  			
	});	
}

function showLoader() {
  $('#eems-browser-widget').fadeOut('slow');
  $('#eems-loader').show();
}

// Error creating an EEM
function showEEMsErrorMsg() {
  $('#eems-loader').hide();					  
  $('#eems-upload-progress').hide();
  $('#eems-error').html("<span class=\"errorMsg\">Error creating EEM.</span>").show();							  						
}

// Error uploading PDF
function showPDFErrorMsg() {
	var eem_pid = window._pid; 
		
  $('#eems-loader').hide();				
  $('#eems-upload-progress').hide();

	var msg = 
	  "Unable to upload the requested file. The EEMs record has been created and the request should not be tried again." + 
	  "<p>What you can do:</p>" + 
	  "<ol><li>Download the file to your desktop from the web site. It is likely that the way in which the web site delivers " + 
	  "the file to the user makes it impossible for the EEMs application to upload it on your behalf.</li>" + 
	  "<li>Upload the file into the existing request by going to the <a href=\"/view\" target=\"_blank\">EEMs Dashboard</a>, finding the ";  
	
	if (eem_pid != undefined) {
		msg = msg + "<a href=\"/view/" + trimmedId(eem_pid) + "\" target=\"_blank\">record of this request</a>";
	} else {
		msg = msg + "record of this request";
	}
	
	msg = msg + " and using the \'Browse\' button " + 
	  "next to the empty \"Local copy of this file\" field.</li></ul>"

  $('#eems-error').html("<div class=\"errorMsgPDF\">" + msg + "</div>").show();

  if (eem_pid != undefined) {
	  var pars1 = { 'authenticity_token': window._token, 'eem[status]': 'Created', 'eem[requestDatetime]': '' };
    eemUpdate(eem_pid, pars1);

	  var selectorName = $('#eem_selectorName').val();
    var logMsg = 'File upload failure for ' + selectorName;
    var pars2 = { 'authenticity_token': window._token, 'entry': logMsg };
    addLogEntry(eem_pid, pars2, false);
  }

}

// Update file upload progress bar
function update() {
	$.getJSON('/content_files/' + content_file_id, function(data) { 
		
		if (data == null || data.attempts == 'failed') {
		  showPDFErrorMsg(); 
		  return;
		}  
		
	  var percent = parseInt(data.percent_done);	  
	  delayedJobTimeout += 500; // increment delayed job time by 0.5 sec
  
	  if (!isNaN(percent)) {
		  $('#eems-percent-done').html(percent + ' %');
		  $('#eems-progress-bar').css({'width' : (percent*3) + 'px', 'height' : '10px' });

		  if (percent == 100) {
		    $('#upload-progress-text').hide();
		    $('#upload-complete-text').show();
		    $('#eems-links').show();
		    clearTimeout(timeoutId);
		    return;			
			}
    } else {
	    // if delayedJobTimeout >= 10 sec, quit uploader process
	    if (delayedJobTimeout >= 10000) {
		    showPDFErrorMsg();
		    clearTimeout(timeoutId);
		    return;
	    }
    }
	});

	timeoutId = setTimeout(update, 500);
}

// Submit to tech services
function sendToTechServices(pid) {
  var pars = { 'authenticity_token': window._token };

  $.ajax({
	  url: '/eems/' + pid + '/submit_to_tech_services', 
	  type: 'PUT', 
	  data: pars, 
	  success: function(status) {
	  }, 
	});
}

// Enable/disable 'Save to dashboard' button
function toggleSaveToDashboard(widgetName) {
	if (widgetName == 'eems-browser-widget') {
	  if ($('#eem_bw_title').val() != '' && $('#contentUrl').val() != '' ) {
		  $('#eem_bw_save_to_dashboard').attr("disabled", false);
	  }	
	  else {
		  $('#eem_bw_save_to_dashboard').attr("disabled", true);
	  }		
	}

	if (widgetName == 'eems-desktop-widget') {
	  if ($('#eem_dw_title').val() != '' && $('#content_upload').val() != '' ) {
		  $('#eem_dw_save_to_dashboard').attr("disabled", false);
	  }	
	  else {
		  $('#eem_dw_save_to_dashboard').attr("disabled", true);
	  }		
	}	
}

// Enable/disable 'Send to Tech Services' button
function toggleSendToTechServices(widgetName) {
	if (widgetName == 'eems-browser-widget') {
	  if ($('#eem_bw_title').val() != '' && $('#contentUrl').val() != '' && 
	      (($('#eem_bw_paymentType').val() == 'Free' && ( $('#eem_bw_copyrightStatus').val() == 'Public access OK' || $('#eem_bw_copyrightStatus').val() == 'Stanford access OK')) ||  
		     ($('#eem_bw_paymentType').val() == 'Paid' && $('#eem_bw_payment_fund').val() != '' && $('#eem_bw_payment_fund').val() != defaultValues.payment_fund))) {
	    $('#eem_bw_send_to_tech_services').removeAttr("disabled");
	  }
	  else {
	 	  $('#eem_bw_send_to_tech_services').attr("disabled", true);
	  }			
	}

	if (widgetName == 'eems-desktop-widget') {
	  if ($('#eem_dw_title').val() != '' && $('#content_upload').val() != '' && 
	      (($('#eem_dw_paymentType').val() == 'Free' && ( $('#eem_dw_copyrightStatus').val() == 'Public access OK' || $('#eem_dw_copyrightStatus').val() == 'Stanford access OK')) ||  
		     ($('#eem_dw_paymentType').val() == 'Paid' && $('#eem_dw_payment_fund').val() != '' && $('#eem_dw_payment_fund').val() != defaultValues.payment_fund))) {
	    $('#eem_dw_send_to_tech_services').removeAttr("disabled");
	  }
	  else {
	 	  $('#eem_dw_send_to_tech_services').attr("disabled", true);
	  }			
	}	
}

function trimmedId(id) {
	if (id != null && id != undefined) {
		return id.replace(/^druid:/, '');		
	}
	else {
		return '';
	}
}

function isValidFileType(url) {
	var strRegex = allowedFileTypes.replace(/ /g, "|");
	strRegex = strRegex.replace(/\|$/, "");
	strRegex = "\\.(" + strRegex + ")$";
	
	var regex = new RegExp(strRegex, "i");

	if (regex.test(url)) { return true; }
	
	return false;
}
