<?php
error_reporting(1);
$target='/www/new';
$cmd="cd $target && git pull origin master";
$output = shell_exec($cmd);
echo "<pre>";
print_r($output);
echo "</pre>";

