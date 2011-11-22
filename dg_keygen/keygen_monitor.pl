#! C:\Perl\bin\perl.exe

chdir("C:/bk/pdfprint_cmd");

$watch_file = "C:\\wamp\\www\\dg\\dg_code.txt";
$serial_file = "C:\\dg_serial.txt";

sub logger {
  $message = $_[0];

  $logfile = "C:\\bk\\serenity\\$location" . "_log.txt";

  ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

  $year = $year + 1900;
  $mon = $mon + 1;

  if($mday < 10) { $mday = "0$mday"; }
  if($mon < 10) { $mon = "0$mon"; }
  if($min < 10) { $min = "0$min"; }
  if($hour < 10) { $hour = "0$hour"; }

  my $did = "$year$mon$mday $hour:$min";
  my $to_log = "[PDF] $did - $message\n";

  #open(LOG, ">>$logfile");
  #print LOG "$to_log";
  #close(LOG);

  print $to_log;
}

#
###
# THE SCRIPT!
###
#



logger("DG KEYGEN MONITOR WOOT WOOT");


while(1) {

  if(-e $watch_file && !-e $serial_file) {
    logger("Saw $watch_file");
    open(FILE, $watch_file);
    $code = <FILE>;
    close(FILE);
    unlink($watch_file);  
    chomp($code);
    if($code) {
      logger("Saw Code: $code");
      logger("Launching keygen, hoping for the best.");
      system("start /max C:\\auto_dg_keygen.exe $code");
      sleep(30);
      logger("Ready for work again");
    }

  }

  sleep(5);
}