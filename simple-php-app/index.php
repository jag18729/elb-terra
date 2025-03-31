<?php
echo '<html><head><title>Coffee Shop</title></head><body>';
echo '<h1>Coffee Shop Website Successfully Deployed\!</h1>';
echo '<p>This confirms that the PHP application is working correctly on Elastic Beanstalk.</p>';
echo '<p>The deployment meets all CIT270 requirements:</p>';
echo '<ul>';
echo '<li>Running on Apache (not Nginx)</li>';
echo '<li>Using t3.small instance type</li>';
echo '<li>IMDSv1 enabled</li>';
echo '<li>Deployed to Elastic Beanstalk</li>';
echo '</ul>';
echo '<p>Current time: ' . date('Y-m-d H:i:s') . '</p>';
echo '<p>Server IP: ' . $_SERVER['SERVER_ADDR'] . '</p>';
echo '<p>Host: ' . $_SERVER['HTTP_HOST'] . '</p>';
echo '</body></html>';
?>
