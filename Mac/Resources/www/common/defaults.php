<?
function readDefault($key) {
  $value = exec("/usr/bin/defaults read com.blacktree.Telekinesis \"$key\"", $output, $return);
  if ($return) return NULL;
  return $value;
}
function writeDefault($key, $value) {
	return exec("/usr/bin/defaults write com.blacktree.Telekinesis \"$key\" \"$value\"");
}
?>