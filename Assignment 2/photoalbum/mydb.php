<?php
/**
* 	Interacting with MySQL DB in RDS
*
*	@author Swinburne University of Technology
*/
require 'photo.php';
require_once 'constants.php';
require_once 'utils.php';

class MyDB 
{
	private $dbh;
	private $utils;
	
	public function __construct() {
		try {
			$this->utils = new Utils();
			$dsn = "mysql:host=".DB_ENDPOINT.";dbname=".DB_NAME;
			$this->dbh = new PDO ( $dsn, DB_USERNAME, DB_PWD );
			$this->dbh->setAttribute ( PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
		} catch ( PDOException $e ) {
			error_log($e);
			$GLOBALS['html_template'] = $this->utils ->showErrorMsg($GLOBALS['html_template'], $e->getMessage() . PHP_EOL);
		}
	}
	
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
			$GLOBALS['html_template'] = $this->utils ->showErrorMsg($GLOBALS['html_template'], $e->getMessage() . PHP_EOL);
		}
	}
	
	public function addPhoto($photo) {
		try {
			$sql = "INSERT INTO ".DB_PHOTO_TABLE_NAME." (".DB_PHOTO_TITLE_COL_NAME.", ".DB_PHOTO_DESCRIPTION_COL_NAME.", ".DB_PHOTO_CREATIONDATE_COL_NAME.", ".DB_PHOTO_KEYWORDS_COL_NAME.", ".DB_PHOTO_S3REFERENCE_COL_NAME .") VALUES(?,?,?,?,?);";
			$this->dbh->prepare ( $sql )->execute ( [
					$photo->getName(),
					$photo->getDescription(),
					$photo->getCreationDate(),
					$photo->getKeywords(),
					$photo->getS3Reference(),
			] );
			return $this->dbh->lastInsertId();
		} catch ( PDOException $e ) {
			error_log($e);
			$GLOBALS['html_template'] = $this->utils ->showErrorMsg($GLOBALS['html_template'], $e->getMessage() . PHP_EOL);
		}
	}
	
	public function getPhotoByName($name){
		try {
			$stmt = $this->dbh->prepare("SELECT * FROM ".DB_PHOTO_TABLE_NAME." WHERE ".DB_PHOTO_TITLE_COL_NAME."='$name' LIMIT 1");
			$stmt->execute();
			$row = $stmt->fetch();
			if($row){
				$photo = new Photo ( $row [DB_PHOTO_TITLE_COL_NAME], $row [DB_PHOTO_DESCRIPTION_COL_NAME]) ;
				return $photo;
			}else{
				return null;
			}
		} catch ( PDOException $e ) {
			error_log($e);
			$GLOBALS['html_template'] = $this->utils ->showErrorMsg($GLOBALS['html_template'], $e->getMessage() . PHP_EOL);
		}
	}
}
?>