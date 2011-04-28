
var EEMsWidget = { 
  popup_width : 490, 
  popup_height : 510, 
  
  showPopOver : function(baseUrl){                      
    if (document.getElementById('eems_popup') != null) {
      document.getElementById('eems_popup').style.display='inline';
      return;
    }

    var popup = document.createElement('div');
    var popup_style = 'overflow: auto; top: 10px; position: fixed; text-align: left; ' + 
      'font: normal normal normal 9px/1.5 Tahoma,Arial; z-index: 100000; border-color: 1px solid blue';
    popup.id = 'eems-popup';
    popup.setAttribute('style', popup_style);
    popup.style.left = (document.body.clientWidth - this.popup_width - 10) + 'px';
    popup.style.width = this.popup_width + 'px';
    popup.style.height = this.popup_height + 'px';
    popup.onmouseover = function() { popup.style.cursor = 'move'; }
    popup.onmousedown = function() { popup.style.cursor = '-moz-grabbing'; }
    popup.onmouseup = function() { popup.style.cursor = ''; }
     
    var popup_container = document.createElement('div');
    var popup_container_style = 'position: absolute; top: 0; left: 0; ' + 	
      'overflow: auto; background-color: #660000; opacity: 0.6; filter: alpha(opacity=60); ' + 
      '-moz-border-radius: 10px; -webkit-border-radius: 10px';
    popup_container.setAttribute('style', popup_container_style);
    popup_container.style.width = this.popup_width + 'px';
    popup_container.style.height = this.popup_height + 'px';
 
    var popup_content = document.createElement('div');
    var popup_content_style = 'top: 15px; left: 15px; clear: both; position: absolute; margin: 0;' +
      'border: 1px solid #666; -moz-border-radius: 5px; -webkit-border-radius: 5px; background-color: #f6f2f6;';
    popup_content.id = 'popup_content';
    popup_content.setAttribute('style', popup_content_style);    
    popup_content.style.width = (this.popup_width - 32) + 'px';
    popup_content.style.height = (this.popup_height - 32) + 'px';
    popup_content.style.backgroundColor = '#fff';
    
    var close_link = document.createElement('a');
    var close_link_style = 'background-color: #a46666; color: #fff; font-weight: bold; position: absolute; -moz-border-radius: 3px; -webkit-border-radius: 3px;' +
      'right: 6px; top: 6px; padding: 0 5px 2px 5px; text-decoration: none; border-width: 0;';    
    close_link.setAttribute('style', close_link_style);
    close_link.setAttribute('href', '#');
    close_link.setAttribute('onmouseover', "this.style.backgroundColor = '#770000';");
    close_link.setAttribute('onmouseout', "this.style.backgroundColor = '#a46666';");
    close_link.setAttribute('onclick', "javascript:(function(){elemWidget=document.getElementById('eems-popup');elemWidget.parentNode.removeChild(elemWidget);}())");
    
    close_link.innerHTML = 'x';
    popup_content.appendChild(close_link);
    
    var iframeForm = document.createElement('iframe');
    iframeForm.style.width = (this.popup_width - 50) + 'px';
    iframeForm.style.height = (this.popup_height - 40) + 'px';
    iframeForm.style.overflow = "hidden";
    iframeForm.style.marginLeft = '5px';
    iframeForm.style.borderWidth = 0;
    iframeForm.id = 'iframeForm';
    iframeForm.name = 'iframeForm';
    iframeForm.src = baseUrl + '/eems/new?referrer=' + parent.location.href;

    popup_content.appendChild(iframeForm);
    
    popup.appendChild(popup_container);
    popup.appendChild(popup_content);
    
    if (document.getElementsByTagName('body')[0] != null && document.getElementsByTagName('body')[0] != undefined) {
	    document.getElementsByTagName('body')[0].appendChild(popup);	
    } else {
	    alert('Sorry, EEMs widget cannot be opened in this page');
	    return;
    }
    
    this.setupWidgetDragging();
  },
 
  setupWidgetDragging : function() {
    var attrs = {
      isDragged : false,
      left : 0,
      top : 0, 
      drag : { left : 0, top : 0 },    
      start : { left : 0, top : 0 }    
    };       
 
    var dragLimits = {
      left : { min : 0, max: (this.f_clientWidth() - this.popup_width) }, 	
      top : { min : 0, max: (this.f_clientHeight() - this.popup_height) }
    };

    var elemPopup = document.getElementById('eems-popup');
         
    var startWidgetMove = function(event) {
      if (!event) event = window.event; // required for IE
  
      attrs.drag.left = event.clientX;
      attrs.drag.top  = event.clientY;
      attrs.start.left = parseFloat(elemPopup.style.left.replace(/px/, ''));
      attrs.start.top  = parseFloat(elemPopup.style.top.replace(/px/, ''));
      attrs.isDragged  = true;      
    };
  
    var processWidgetMove = function(event) {      
      if (!event) event = window.event; // required for IE
      
      if (attrs.isDragged) {
        attrs.left = attrs.start.left + (event.clientX - attrs.drag.left);      
        attrs.top = attrs.start.top + (event.clientY - attrs.drag.top);

        if (attrs.left < dragLimits.left.min) attrs.left = dragLimits.left.min;        
        if (attrs.left > dragLimits.left.max) attrs.left = dragLimits.left.max;        
        if (attrs.top < dragLimits.top.min) attrs.top = dragLimits.top.min;        
        if (attrs.top > dragLimits.top.max) attrs.top = dragLimits.top.max;          

        if (attrs.top < 0) attrs.top = 10;
        if (attrs.left < 0) attrs.left = 10;

        elemPopup.style.cursor = '-moz-grabbing';
        elemPopup.style.left = attrs.left + 'px';
        elemPopup.style.top = attrs.top + 'px';
      }
    };
    
    var stopWidgetMove = function(event) {
      attrs.isDragged = false;      
      elemPopup.style.cursor = '';
    };
  
    elemPopup.onmousedown = startWidgetMove; 
    elemPopup.onmousemove = processWidgetMove; 
    elemPopup.onmouseup = stopWidgetMove;
    elemPopup.onmouseleave = stopWidgetMove;
    elemPopup.onmouseout = stopWidgetMove;
    elemPopup.ondragstart = function() { return false; } // for IE  
  },

  // From -- http://www.softcomplex.com/docs/get_window_size_and_scrollbar_position.html
  f_clientWidth : function() {
	return this.f_filterResults (
	  window.innerWidth ? window.innerWidth : 0,
	  document.documentElement ? document.documentElement.clientWidth : 0,
	  document.body ? document.body.clientWidth : 0
	);
  }, 

  f_clientHeight : function() {
	return this.f_filterResults (
	  window.innerHeight ? window.innerHeight : 0,
	  document.documentElement ? document.documentElement.clientHeight : 0,
	  document.body ? document.body.clientHeight : 0
	);
  },   

  f_filterResults : function(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;	
	if (n_docel && (!n_result || (n_result > n_docel))) n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
  }

}
