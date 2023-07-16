<!DOCTYPE html>
<html>
<head>
	<title>Photo Album</title>
</head>
<body>
	<h1>Photo Uploader</h1>

	<?php
	?>

	<form method="post" action="<?php?>">
		<fieldset>
			<p class="row">
				<label for="photo_title">Photo title:</label>
				<input type="text" name="photo_title" id="photo_title" />
			</p>
			<p class="row">
				<label for="photo_file">Select a photo:</label>
				<input type="file" name="photo_file" id="photo_file" />
			</p>
			<p class="row">
				<label for="description">Description:</label>
				<input type="text" name="description" id="description" />
			</p>
			<p class="row">
				<label for="date">Date:</label>
				<input type="date" name="date" id="date" />
			</p>
			<p class="row">
				<label for="photo_keyword">Keywords (comma-delimited, eg. keyword1, keyword2,...):</label>
				<input type="text" name="photo_keyword" id="photo_keyword" />
			</p>
			<p class="row">
				<input type="submit" value="Upload" />
			</p>
		</fieldset>
	</form>
    <p><a href="photolookup.php">Photo Lookup</a></p>
</body>
</html>