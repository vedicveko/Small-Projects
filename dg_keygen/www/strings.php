<?PHP

$curr_year = date('Y');

$info = array(
'statread' => array(
  'name' => 'SXR Teleradiology', 
  'other_names' => 'sxrteleradiolgy, overreads, xrayreads, x-rayreads, theteleradiology'
  ),

'sxrradiology' =>  array(
  'name' => 'SXR Radiology', 
  'other_names' => 'sxrrad'
  ),

'southeastxray' =>  array(
  'name' => 'Southeast X-Ray', 
  'other_names' => ''
  )
);

$server_name = $_SERVER['SERVER_NAME'];
$replace = array('www.', '.com', '.net', '.org', '.info');
foreach($replace as $str) {
  $server_name = str_replace($str, '', $server_name);
}

foreach($info as $key => $value) {
  if(strstr($value['other_names'], $server_name)) {
    $server_name = $key;
  }
}

if(isset($info["$server_name"])) {
  $i = $info["$server_name"];
}
else {
  $i = $info['sxrradiology'];
}

$website_name = $i['name'];
$temp_title = $website_name;
$name = $i['name'];


?>
