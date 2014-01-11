#!/usr/bin/php
<?PHP

require_once('config.php');

function make_links_clickable($text){
    return preg_replace('!(((f|ht)tp(s)?://)[-a-zA-Z.-..-.()0-9@:%_+.~#?&;//=]+)!i', '<a href="$1">$1</a>', $text);
}

function wpPostXMLRPC($title,$body,$keywords='',$encoding='UTF-8') {

  $username = 'reddit';
  $password = 'reddit42';
  $category = 'Reddit';
  $url = 'http://xrayreads.com/xmlrpc.php';

  $title = htmlentities($title,ENT_NOQUOTES,$encoding);
  $keywords = htmlentities($keywords,ENT_NOQUOTES,$encoding);

  $content = array(
    'title'=>$title,
    'description'=>$body,
    'mt_allow_comments'=>0,  // 1 to allow comments
    'mt_allow_pings'=>0,  // 1 to allow trackbacks
    'post_type'=>'post',
    'mt_keywords'=>$keywords,
    'categories'=>array($category)
  );
  $params = array(0,$username,$password,$content,true);
  $request = xmlrpc_encode_request('metaWeblog.newPost',$params);

  $ch = curl_init();
  curl_setopt($ch, CURLOPT_POSTFIELDS, $request);
  curl_setopt($ch, CURLOPT_URL, $url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
  curl_setopt($ch, CURLOPT_TIMEOUT, 1);
  $results = curl_exec($ch);
  curl_close($ch);
  return($results);

}

# Get Reddit Info
function reddit($sub) {

  $ret = array();

  $reddit_base = 'http://www.reddit.com/r/';
  $raw = file_get_contents("$reddit_base/$sub.json");

  $arr = json_decode($raw, true);

  if(!isset($arr['data']['children'])) {
    logger("reddit(): Bad data back");
    return(array());
  }

  foreach($arr['data']['children'] as $post) {
    if(isset($post['data'])) {
      $post = $post['data'];
    }
    else {
      continue;
    }

    $ret[] = $post;

  }

  return($ret);

}

function reddit_comment($link) {

  $ret = array();

  $reddit_base = 'http://www.reddit.com/';
  $raw = file_get_contents("$reddit_base/$link.json");

  $arr = json_decode($raw, true);

  if(!isset($arr[1]['data']['children'])) {
    logger("reddit_comment(): Bad data returned.");
    return('There are no comments at this time, but check the full comments for further updates.');
  }

  foreach($arr[1]['data']['children'] as $post) {
    if(isset($post['data'])) {
      $post = $post['data'];
    }
    else {
      continue;
    }

    $str = "<b>$post[author]:</b> $post[body]<br><br>\n\n";
    if(isset($post['replies'])) {
      if(isset($post['replies']['data']['children'])) {
        if(isset($post['replies']['data']['children'][0]['data'])) {
          $reply = $post['replies']['data']['children'][0]['data'];
          $str .= "<b>$reply[author]:</b> $reply[body]<br>\n";
        }
      }
    }

    return($str);

  }

}



$reddits = reddit('Radiology');

### Run through the posts and add any new ones to our DB
foreach($reddits as $post) {

  $query = "SELECT seq FROM reddit_posts WHERE reddit_id = '$post[id]' LIMIT 1";
  $result = mysql_query($query) or logger($query . ' -> ' . mysql_error());
  $row = mysql_fetch_array($result, MYSQL_ASSOC);
  if($row['seq']) {
//    logger("$post[id]: ($post[title]) has been seen before.");
    continue;
  }

  logger("$post[id]: ($post[title]) is new.");

  $query = "INSERT INTO reddit_posts(`reddit_id`, `title`, `thumbnail`, `permalink`, `url`, `complete_post`) " .
           "VALUES(\"$post[id]\", \"" . mysql_real_escape_string($post['title']) . "\", \"$post[thumbnail]\", \"$post[permalink]\", '$post[url]', \"" . base64_encode(serialize($post)) . "\")";
  mysql_query($query) or logger($query . ' -> ' . mysql_error());
  sleep(2);
}

### Now run through all that have not been reposted
$query = "SELECT * FROM reddit_posts WHERE reposted = 0";
$result = mysql_query($query) or logger($query . ' -> ' . mysql_error());
while($row = mysql_fetch_array($result, MYSQL_ASSOC)) {

  logger("Attempting to repost -> $row[title]");

  $title = '';
  $body = '';

  $comment = reddit_comment($row['permalink']);
  $img = '';

  if(strstr($row['url'], 'http://imgur.com/a/')) { // IMGUR ALBUM
    $img = '<iframe class="imgur-album" width="100%" height="550" frameborder="0" src="' . $row['url'] . '/embed"></iframe>';
  }
  else if(strstr($row['url'], 'http://imgur.com/')) { // IMGUR Page
    $img_id = str_replace('http://imgur.com/', '', $row['url']);
    $img = '<a href="http://imgur.com/' . $img_id . '"><img src="http://i.imgur.com/' . $img_id . '.jpg" title="Hosted by imgur.com" alt="" /></a>';
  }
  else if(strstr($row['url'], 'http://i.imgur.com/')) { // IMGUR Direct to IMG
    $img_file = str_replace('http://i.imgur.com/', '', $row['url']);
    list($img_id, $img_ext) = explode('.', $img_file);
    $img = '<a href="http://imgur.com/' . $img_id . '"><img src="http://i.imgur.com/' . $img_file . '" title="Hosted by imgur.com" alt="" /></a>';
  }
  else {
    $img = "";
  } 

  if(strlen($comment) < 25) {
    $comment .= "   <!--noadsense-->";
  }

  $title = $row['title'];
  $title = preg_replace("/\([^)]+\)/", '', $title);

  $comment = make_links_clickable($comment);

  $body = "$img<br><br>\n\n$comment<br><br>\n\n<a href=\"http://www.reddit.com$row[permalink]\">View Full Post and Comments</a>";

  if($title && $body) {
    if($img) {
      logger("Wordpressing: $title -> $body");
      $ret = wpPostXMLRPC($title, $body);
      logger("All good.");
    }
    mysql_query("UPDATE reddit_posts SET reposted = 1 WHERE seq = $row[seq] LIMIT 1");
  }
  logger("Sleeping for 5s...");
  sleep(5);
}

?>
