<?php
/**
* 	All constants defined here
*
*	@author Swinburne University of Technology
*
*	============ READ ME !!! ============ 
* 	============ READ ME !!! ============ 
* 	============ READ ME !!! ============ 
*	This project requires AWS SDK for PHP. 
*	SSH into your EC2 and execute the following two commands to install the SDK:
*	1. Download the zip file that contains AWS SDK PHP onto /var/www/html directory
*	wget -P /var/www/html http://docs.aws.amazon.com/aws-sdk-php/v3/download/aws.zip
*	2. Unzip the downloaded file onto a new directory called "aws", which sits in /var/www/html directory
*	unzip /var/www/html/aws.zip -d /var/www/html/aws
*
*	Make sure the directory structure is correct so that the AWS SDK can be invoked.
*	var
*	└───www
*		└───html
*			└───aws (created above in Command 2. This directory contains AWS SDK for PHP)
*	    		│   AWS
*	    		│   aws-autoloader.php
*	   			│   ... 
*	   			│
*			└───photoalbum (this directory contains source files of the PhotoAlbum website)
*	    		│   uploads (this directory stores images before they are uploaded to S3, for more deets see photouploader.php)
*	   			│   album.php 					(executable) display all images in DB
*	   			│   constants.php 				Constants defined here
*	   			│   defaultstyle.css			CSS style for the website
*	   			│   mydb.php					Interact with RDS DB
*	   			│   photo.php					Photo object class
*	   			│   photouploader.php			(executable) upload image to S3 and RDS
*	   			│   photouploadtemplate.html	HTML template for the photo uploading function
*	   			│   utils.php					some supporting methods
*	   			│
*
*	The values of the constant variables with "[ACTION REQUIRED]" in the comment must be updated. The current values are just examples.
*	You need to replace the values of those constant variables with values specific to your setup.
*
* 	============ READ THE ABOVE !!! ============ 
* 	============ READ THE ABOVE !!! ============ 
* 	============ READ THE ABOVE !!! ============ 
*/

// [ACTION REQUIRED] your full name
define('STUDENT_NAME', 'Luu Tuan Hoang');
// [ACTION REQUIRED] your Student ID
define('STUDENT_ID', '104180391');
// [ACTION REQUIRED] your tutorial session
define('TUTORIAL_SESSION', 'Saturday 08:00AM');

// [ACTION REQUIRED] name of the S3 bucket that stores images
define('BUCKET_NAME', 'luutuanhoang-104180391-assignment2');
// [ACTION REQUIRED] region of the above bucket
define('REGION', 'us-east-1');
define('S3_BASE_URL','https://'.BUCKET_NAME.'.s3.amazonaws.com/');

// [ACTION REQUIRED] name of the database that stores photo meta-data (note that this is not the DB identifier of the RDS instance)
define('DB_NAME', 'photoalbum');
// [ACTION REQUIRED] endpoint of RDS instance
define('DB_ENDPOINT', 'assignment2-db.c9pefcwlxpd8.us-east-1.rds.amazonaws.com');
// [ACTION REQUIRED] username of your RDS instance 
define('DB_USERNAME', 'admin');
// [ACTION REQUIRED] password of your RDS instance
define('DB_PWD', 'admin123');

// [ACTION REQUIRED] name of the DB table that stores photo's meta-data
define('DB_PHOTO_TABLE_NAME', 'photo_metadata');
// The table above has 5 columns:
// [ACTION REQUIRED] name of the column in the above table that stores photo's titles
define('DB_PHOTO_TITLE_COL_NAME', 'title');
// [ACTION REQUIRED] name of the column in the above table that stores photo's descriptions
define('DB_PHOTO_DESCRIPTION_COL_NAME', 'description');
// [ACTION REQUIRED] name of the column in the above table that stores photo's creation dates
define('DB_PHOTO_CREATIONDATE_COL_NAME', 'creationdate');
// [ACTION REQUIRED] name of the column in the above table that stores photo's keywords
define('DB_PHOTO_KEYWORDS_COL_NAME', 'keywords');
// [ACTION REQUIRED] name of the column in the above table that stores photo's links in S3 
define('DB_PHOTO_S3REFERENCE_COL_NAME', 'reference');

// [ACTION REQUIRED] name (ARN can also be used) of the Lambda function that is used to create thumbnails
define('LAMBDA_FUNC_THUMBNAILS_NAME', 'CreateThumbnail');

?>