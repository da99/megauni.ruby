<?php
  $heroku = 'http://surfer-hearts.heroku.com';
  $path = $heroku . $_SERVER['REQUEST_URI'];
  if ( preg_match( '/\.(js|css|png|jpg|gif)/', $path) > 0 )
  { 
    header("Location: $path");
    exit;
  };
  
  $homepage = file_get_contents( $path );
  if ( $homepage )
    echo $homepage;
  else
  {
    $path_500 = $heroku . "/500.html";
    echo file_get_contents( $path_500 );
  };
?>

