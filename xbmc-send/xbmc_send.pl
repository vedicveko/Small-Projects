#! C:\Perl\bin\perl.exe
## This script will sanitize messages from uTorrent and send them to XBMC.
## xbmc_send.exe <title> <message>

chdir("C:\\xbmc-send");

use LWP;
use LWP::Simple;
use File::Copy;
use File::Path;
use File::Basename;

sub logger {
 
  my $message = $_[0];

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

  $year = $year + 1900;
  $mon = $mon + 1;

  if($mday < 10) { $mday = "0$mday"; }
  if($mon < 10) { $mon = "0$mon"; }
  if($min < 10) { $min = "0$min"; }
  if($hour < 10) { $hour = "0$hour"; }
  if($sec < 10) { $sec = "0$sec"; }

  my $did = "$year$mon$mday $hour:$min:$sec";
  my $to_log = "$did - $message\n";

  if($enable_logging) {
    open(LOG, ">>log.txt");
    print LOG "$to_log";
    close(LOG);
  }

  print $to_log;
  return($to_log);
}

sub get_webpage_content {
  my($url, $user, $pass, $server, $realm) = @_;

  $sleep_time = 5;
  $content = '';
  $x = 0;
  while(!$content) {
    $browser = LWP::UserAgent->new;
    $browser->timeout(10);
    if($user && $pass && $realm && $server) {
      $browser->credentials(
        $server,
        $realm,
        $user => $pass
      );
    }
    $response = $browser->get($url);
    $content = $response->content;
    $x++;
    if(!$content && $x == 5) {
      logger("Couldn't retrieve $url, sleeping");
      sleep($sleep_time);
      $x = 0;
    }
  }

  undef($browser);

  return($content);
}

open(FILE, 'config.txt') or logger("Could not open config");
@cfg = <FILE>;
close(FILE);
  
foreach $line (@cfg) {
 	if(!$line) {
   		next;
   	}
  	if($line =~ /#/) {
     		next;
  	}
  	($name, $value) = split(/=/, $line);
  	chomp($value);
  	$$name = $value;
}

$title = $ARGV[0];
$message = $ARGV[1];

if(!$host || !$title || !$message) {
  logger("Missing args");
  exit;
}

$orig_message = $message;

logger("====== NEW RUN ======");
logger("Title: $title");
logger("Message: $message");

if($title =~ /Queued/) {
  logger("I don't care about queuing");
  exit;
}

if($title =~ /^Finished/) {
  logger("I don't care about torrents being removed");
  exit;
}

$tmessage = $message;
my ($ext) = $tmessage =~ /(\.[^.]+)$/;

if($ext && $tmessage) {
  $message =~ s/$ext$//g;
}

# Take care of everything in strings.txt
open(STRINGS, 'strings.txt');
@strings = <STRINGS>;
close(STRINGS);

$num = @strings;

logger("Checking $num strings");

foreach $str (@strings) {
  chomp($str);
  if($str =~ /#/ || !$str) {
    next;
  }
  $message =~ s/$str//gi;
}

# Fix up some spaces
$message =~ s/\[/ \[/g;
$message =~ s/\[/\(/g;
$message =~ s/\]/\)/g;

$message =~ s/\./ /g;

$message =~ s/   / /g;
$message =~ s/  / /g;

$message =~ s/ $//g;

# Send it
logger("Sending: $message");

$url = "http://$host/xbmcCmds/xbmcHttp?command=ExecBuiltIn(Notification($title, $message," . $display_time . "000))";
logger("$url");

$ret = get_webpage_content($url);
$ret =~ s/\n//g;
chomp($ret);
logger("XBMC says: ($ret)");

if(!$rename_files || $title !~ /Download Finished/) {
  exit;
}

### Now we're going to figure out if the original $message was a file or directory.
### If a file, rename it 
### If a directory, find the file inside, move it up one and rename.

$file = $ARGV[2];
$label = $ARGV[3];

logger("File: $file");
logger("Label: $label");

if(!$file) {
  logger("No file given (arg 3)");
  exit;
}

if($label && !$ok_to_rename_labels) {
  logger("Config prohibits renaming a labeled file.");
  exit;
}

if (-d $file) { ### ITS A DIRECTORY
  logger("Working with directory");
  opendir(DIR, $file);
  @in_dir = readdir(DIR);
  close(DIR);  
  
  $moved = 0;

  foreach $found (@in_dir) {
	if($found =~ /.avi$/i || $found =~ /.mp4$/i || $found =~ /.wmv$/i || $found =~ /.mkv$/i) {
	  $filesize = -s "$file\\$found";
	  if($filesize < 50000000) { # 50MBish
	    logger("Skipping, too small $filesize");
	    next;
	  }

	  logger("Saw: $found");
	  
	  $tfound = $found;
      my ($ext) = $tfound =~ /(\.[^.]+)$/;
	  
	  if($ext) {
	    $new_name = $message . $ext;
	    move("$file\\$found", "$file\\..\\$new_name");
	    logger("Moved to ..\\$new_name");
		$moved++;
	  }
	  else {
	    logger("Skipping, no ext");
		next;
	  }
	}
	elsif($found =~ /.rar$/i) {
	  logger("Rar file found");
	  system("C:\\xbmc-send\\unrar.exe e -y \"$file\\*.rar\" \"$file\"");

      opendir(DIR, $file);
      @in_dir = readdir(DIR);
      close(DIR);

      foreach $found (@in_dir) {
	    if($found =~ /.avi$/i || $found =~ /.mp4$/i || $found =~ /.wmv$/i || $found =~ /.mkv$/i) {
	      $filesize = -s "$file\\$found";
	      if($filesize < 50000000) { # 50MBish
	        logger("Skipping, too small $filesize");
	        next;
	      }

	      logger("Saw: $found");
	  
    	  $tfound = $found;
          my ($ext) = $tfound =~ /(\.[^.]+)$/;
	  
	      if($ext) {
	       $new_name = $message . $ext;
	       move("$file\\$found", "$file\\..\\$new_name");
	       logger("Moved to ..\\$new_name");
    	   $moved++;
	      }
	      else {
	        logger("Skipping, no ext");
		    next;
	      }
	    }
      }

	}

  }
  
  if($moved) {
    logger("Moved/Renamed $moved files");
	rmtree($file);
  }
}
elsif (-f $file) { ### ITS A FILE
  logger("Working with file");
  $fullpath = $file;
  $dir = dirname($file);
  $file = basename($file);
  $new_name = $message . $ext;
  move($fullpath, "$dir\\$new_name");
  logger("Moved to $new_name");
}
else {
  logger("$file isn't a file or directory. WTF?");
}

