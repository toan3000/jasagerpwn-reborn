/* SiteCatalyst code version: H.14. Copyright Omniture, Inc. More info available at http://www.omniture.com */
/* Owner: Neil Evans */
/************************** CONFIG SECTION ****************************************/
/* Specify the Report Suite(s) */
var s_account="devsunjava";
var sun_dynamicAccountSelection=true;
var sun_dynamicAccountList="sunglobal,sunjava=java.com;devsunjava=.";	
/* Specify the Report Suite ID */
var s_siteid="javac:";
/* Grab JRE Version */
if (typeof deployJava != 'undefined') {
var jreVersions = deployJava.getJREs();
if (jreVersions.length==0){
		var s_prop24 = "None";
	}else{
		s_prop24 = jreVersions[parseInt(jreVersions.length - 1)];
	}
}
/* Remote Omniture JS call  */
var sun_ssl=(window.location.protocol.toLowerCase().indexOf("https")!=-1);
	if(sun_ssl == true) { var fullURL = "https://www.sun.com/share/metrics/metrics_group1.js"; }
		else { var fullURL= "http://www-cdn.sun.com/share/metrics/metrics_group1.js"; }
document.write("<sc" + "ript language=\"JavaScript\" src=\""+fullURL+"\"></sc" + "ript>");
/************************** END CONFIG SECTION **************************************/