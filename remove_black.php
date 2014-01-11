<?PHP

define('MINBLACK', '8');

function get_directory($dir, $level = 0) {
  $ignore = array( 'cgi-bin', '.', '..' );
  $dh = @opendir($dir);
  while( false !== ( $file = readdir($dh))){
    if( !in_array( $file, $ignore ) ){
      if(is_dir("$dir/$file")) {
        echo "\n$file\n";
        get_directory("$dir/$file", ($level+1));
      }
      else {
        if(filesize("$dir/$file") < 10) {
          unlink("$dir/$file");
        }
        echo "$dir/$file - ";

        # Try to figure it based on the date/time
// 20130522002504.jpg	22-May-2013 00:20 	
#  date('YmdHis')
#        $hour = substr($file, 8, 2);
#        print "$hour\n"; exit;



        # Detect the amount of black present
        $cmd = "convert $dir/$file \( -clone 0 -background white -flatten \) \( -clone 0 -background black -flatten \) -delete 0 -scale 1x1\! txt:";
        $ret = `$cmd`;
        $color = parse_ret($ret);
        if($color < MINBLACK) {
          print "$color: ITS BLACK\n";
          unlink("$dir/$file");
        }
        else {
          print "$color: ITS NOT BLACK\n";
        }



      }
    }
  }

  closedir( $dh );
}

function parse_ret($ret) {

  preg_match("/\([0-9]+,[0-9]+,[0-9]+\)/", $ret, $matches);
  if(isset($matches[0])) {
    $t = $matches[0]; 
    $t = str_replace('(', '', $t);
    $t = str_replace(')', '', $t);
    list($r, $g, $b) = explode(',', $t);
    $r += $b;
    $r += $g;
    $avg = $r / 3;
    return($avg);

  }
  else {
    return('1000');
  }
}

get_directory('2013');



?>


