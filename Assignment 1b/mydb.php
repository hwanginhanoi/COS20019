<?php
/**
* 	Interacting with MySQL DB in RDS
*
*	@author Swinburne University of Technology
*/
require 'photo.php';
require_once 'constants.php';

class MyDB 
{
	private $dbh; 
	
	// Constructor, establish a connection to the database in RDS
	public function __construct() {
		try {
			$dsn = "mysql:host=".DB_ENDPOINT.";dbname=".DB_NAME;
			$this->dbh = new PDO ( $dsn, DB_USERNAME, DB_PWD );
			$this->dbh->setAttribute ( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
		} catch ( PDOException $e ) {
			error_log($e);
			echo $e;
		}
	}
	
	// Retrieve all records stored in the database table DB_PHOTO_TABLE_NAME. Return an array of Photo objects
	public function getAllPhotos() {
		$photos = array ();
		try {
			$stm = $this->dbh->query ( 'SELECT * FROM ' . DB_PHOTO_TABLE_NAME );
			foreach ( $stm as $row ) {
				array_push ( $photos, new Photo ( $row [DB_PHOTO_TITLE_COL_NAME], 
												$row [DB_PHOTO_DESCRIPTION_COL_NAME],
												$row [DB_PHOTO_CREATIONDATE_COL_NAME],
												$row [DB_PHOTO_KEYWORDS_COL_NAME],
												$row [DB_PHOTO_S3REFERENCE_COL_NAME]) );
			}
			return $photos;
		} catch ( PDOException $e ) {
			error_log($e);
			echo $e;
		}
	}
}
?>