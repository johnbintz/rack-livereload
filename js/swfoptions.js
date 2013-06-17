WEB_SOCKET_SWF_LOCATION = document.getElementById('swf_options').getAttribute('data-web-socket-swf-location');

var forceSwf = document.getElementById('swf_options').getAttribute('data-force-swf');
if(forceSwf === 'true') {
  WEB_SOCKET_FORCE_FLASH = true;
}