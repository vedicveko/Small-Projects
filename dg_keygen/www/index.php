<?PHP
require_once('strings.php');
$website_name = $i['name'];
$temp_title = $website_name;

$code_file = "C:\\wamp\\www\\dg\\dg_code.txt";

$code = (isset($_GET['code']) ? $_GET['code'] : '');

$serial_str = '';
if($code) {
  file_put_contents($code_file, $code);
}

if(file_exists($code_file) && !file_exists("C:\\dg_serial.txt")) {

  $str = "<META HTTP-EQUIV=\"REFRESH\" CONTENT=\"5\"><img src=http://apps.sxrmedical.com/img/ajax-loader.gif> Waiting on DICOM Gateway serial generation...";

  require_once('header.php'); 
  print $str;
  require_once('footer.php');
  exit;

}
if(file_exists("C:\\dg_serial.txt")) {

  if(file_exists($code_file)) {
    unlink($code_file); 
  }

  $serial = file_get_contents("C:\\dg_serial.txt");
  unlink("C:\\dg_serial.txt");

  $str = "<h3>DG Serial: $serial</h3>";
  
  require_once('header.php'); 
  print $str;
  require_once('footer.php');
  exit;
}


$str = "
$serial_str
<form name=input action=index.php method=get>
<b>Machine Code:</b> <input type=text name=code size=50 />
<input type=submit value=Generate />
</form> 

";

require_once('header.php');
print $str;
require_once('footer.php');
?>