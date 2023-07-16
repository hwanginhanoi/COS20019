<?php
/**
* 	This class contains some supporting methods
*
*	@author Swinburne University of Technology
*/
class Utils
{

	/**
	 * show error message to users
	 *
	 * @param $error_msg - string - message when error
	 * @param $html_template - file - html template file
	 *
	 * @return file -  new html template
	 */
	function showErrorMsg($html_template, $error_msg){
		$html_template = str_replace ( "{{error_msg}}", $error_msg, $html_template );
		$html_template = str_replace ( "{{error_msg_visibility}}", "inline", $html_template );
		return $html_template;
	}
	
	/**
	 * show success message to users
	 *
	 * @param $success_msg - string - message when success
	 * @param $html_template - file - html template file
	 *
	 * @return file - new html template
	 */
	function showSuccessMsg($html_template, $success_msg){
		$html_template = str_replace ( "{{success_msg}}", $success_msg, $html_template );
		$html_template = str_replace ( "{{success_msg_visibility}}", "inline", $html_template );
		return $html_template;
	}
	
	/**
	 * reset all error message and success message
	 * 
	 * @param $html_template - file - html template file
	 *
	 * @return file -  new html template
	 */
	function resetMsg($html_template){
		$html_template = str_replace ( "{{error_msg}}", "{{error_msg}}", $html_template );
		$html_template = str_replace ( "{{error_msg_visibility}}", "{{error_msg_visibility}}", $html_template );
		$html_template = str_replace ( "{{success_msg}}", "{{success_msg}}", $html_template );
		$html_template = str_replace ( "{{success_msg_visibility}}", "{{success_msg_visibility}}", $html_template );
		return $html_template;
	}
	
}
?>