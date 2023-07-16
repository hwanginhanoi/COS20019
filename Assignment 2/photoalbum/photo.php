<?php
/**
* 	Photo class
*
*	@author Swinburne University of Technology
*/
class Photo 
{
	
	private $name;
	private $description;
	private $creation_date;
	private $s3_reference;
	private $keywords;
	
	public function __construct($name, $description, $creation_date, $keywords, $s3_reference) {
		$this->name = $name;
		$this->description = $description;
		$this->creation_date = $creation_date;
		$this->keywords = $keywords;
		$this->s3_reference = $s3_reference;
	}
	
	public function getName() {
		return $this->name;
	}
	
	public function setName($value) {
		$this->name = $value;
	}
	
	public function getDescription() {
		return $this->description;
	}
	
	public function setDescription($value) {
		$this->description = $value;
	}
	
	public function getCreationDate() {
		return $this->creation_date;
	}
	
	public function setCreationDate($value) {
		$this->creation_date = $value;
	}
	
	public function getS3Reference() {
		return $this->s3_reference;
	}
	
	public function setS3Reference($value) {
		$this->s3_reference = $value;
	}
	
	public function getKeywords() {
		return $this->keywords;
	}
	
	public function setKeywords($value) {
		$this->keywords = $value;
	}
}
?>