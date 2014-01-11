<?php
/**
 * Created by JetBrains PhpStorm.
 * User: dean
 * Date: 9/10/12
 * Time: 10:36 AM
 */

function logger($message) {
  $now_time = date("Ymd G:i:s");

  $fh = fopen("camera.log", 'a') or die("can't open file");
  fwrite($fh, "$now_time - $message\n");
  fclose($fh);
  print "$now_time - $message\n";
}

function Execute($command) {

  $command .= ' 2>&1';
  $handle = popen($command, 'r');
  $log = '';

  while (!feof($handle)) {
    $line = fread($handle, 1024);
    $log .= $line;
  }
  pclose($handle);

  return $log;
}

$db = mysql_connect("192.168.1.46", "dean", "dean");
if (!$db) {
  $go_error = 'Could not connect you mysql daemon.';
}

if ($db) {
  if (!mysql_select_db("dean", $db)) {
    $go_error = 'Could not select database.';
  }
}
