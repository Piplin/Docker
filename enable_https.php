#!/usr/bin/env php
<?php
$piplin_path = '/var/www/piplin';

// laravel enable https
$app_server_provider_path = $piplin_path . '/app/Providers/AppServiceProvider.php';
$app_server_provider_content = file_get_contents($app_server_provider_path);
$https_code = "\URL::forceScheme('https');";
if(strpos($app_server_provider_content, $https_code) === false){
    $app_server_provider_content = preg_replace(
        '/function\s+boot\(\s*\)\s*\r?\n?\s*{\r?\n?/',
        "function boot()\n    {\n        {$https_code}\n",
        $app_server_provider_content
    );
    $fh = fopen($app_server_provider_path, 'w');
    fwrite($fh, $app_server_provider_content);
    fclose($fh);
}

// websocket enable https (always uses http server)
$socket_path = $piplin_path . '/socket.js';
$socket_content = file_get_contents($socket_path);
$socket_code = '/^nothing/i.test';
if(strpos($socket_content, $socket_code) === false){
    $socket_content = str_replace('/^https/i.test', $socket_code, $socket_content);
    $fh = fopen($socket_path, 'w');
    fwrite($fh, $socket_content);
    fclose($fh);
}
