var dateFormatMask = "yyyy-mm-dd'T'HH:MM:sso";

$(document).ready(function(){
	$("#searchResultsHeader td").click(function() {
		$(this).find('form').submit();
	});	
});

function addLogEntry(pid, pars, reload) {
	if (pid == undefined) { pid = window._pid; }

  $.ajax({
	  url: '/eems/' + pid + '/log', 
	  type: 'POST', 
	  datatype: 'json', 
	  data: pars, 
	  success: function() { 
		  if (reload) {
	      window.location.reload();
      }
	  }, 
	});	  	
}

function unescapeTags(value) {
  value = value.replace(/>/gi, "&gt;");
  value = value.replace(/</gi, "&lt;");
  return value;
}

function escapeTags(value) {
  value = value.replace(/&gt;/gi, ">");
  value = value.replace(/&lt;/gi, "<");
  value = value.replace(/<br\/?>/gi, "\r");
  return value;
}

// Ajax updater for eem
function eemUpdate(pid, pars) {
	if (pid == undefined) { pid = window._pid; }
  pars['pid'] = pid;

  $.ajax({
    url: '/eems/' + pid + '.json',
    type: 'PUT',
    data: pars,
    success: function(eem) {
    },
  });

  return false;
}

// Ajax updater for content file
function partUpdate(pid, pars) {
	var partPid = window._part_pid;
	
	if (pid == undefined) { pid = window._pid; }
  pars['pid'] = pid;

  if (pid == undefined || partPid == undefined || partPid == '') {
	  return;
  }

  $.ajax({
    url: '/eems/' + pid + '/parts/' + partPid,
    type: 'PUT',
    data: pars,
    success: function(response) {
    },
  });

  return false;	
}

function stripHTMLTags(strInputCode){
 	strInputCode = strInputCode.replace(/&(lt|gt);/g, function (strMatch, p1){
	 	return (p1 == "lt")? "<" : ">";
	});
	
	var strTagStrippedText = strInputCode.replace(/<\/?[^>]+(>|$)/g, "");
  return strTagStrippedText;	
}


function showBrowserWidget() {
	$('#eems-browser-widget-toggle').addClass('eems-widget-tab-active');
	$('#eems-desktop-widget-toggle').removeClass('eems-widget-tab-active');
	$('#eems-desktop-widget').fadeOut();
	$('#eems-browser-widget').fadeIn();
	$('#eems-upload-progress').hide();	  	
	$('#eems-links').hide();	  	
}

function showDesktopWidget() {
	$('#eems-desktop-widget-toggle').addClass('eems-widget-tab-active');
	$('#eems-browser-widget-toggle').removeClass('eems-widget-tab-active');
	$('#eems-browser-widget').fadeOut();	
	$('#eems-desktop-widget').fadeIn();
	$('#eems-upload-progress').hide();	  	
	$('#eems-links').hide();	  	
}


$(document).ready(function() {
	$('#eems-browser-widget-toggle').click(function() {
		showBrowserWidget();
	});

	$('#eems-desktop-widget-toggle').click(function() {
		showDesktopWidget();
	});	
	
	showBrowserWidget();
});
