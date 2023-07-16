<!DOCTYPE html>
<html>
<head>
	<title>Photo Album</title>
</head>
<body>
	<h1>Photo Lookup</h1>

	<?php
	?>

	<form method="post" action="<?php?>">
		<fieldset>
			<p class="row">
				<label for="photo_title">Photo title:</label>
				<input type="text" name="photo_title" id="photo_title" />
			</p>
			<p class="row">
				<label for="photo_keyword">Keywords:</label>
				<input type="text" name="photo_keyword" id="photo_keyword" />
			</p>
			<p class="row">
				<label for="date_from">From date:</label>
				<input type="date" name="date_from" id="date_from" />
			</p>
			<p class="row">
				<label for="date_to">To date:</label>
				<input type="date" name="date_to" id="date_to" />
			</p>
			<p class="row">
				<input type="submit" value="Search" />
			</p>
		</fieldset>
	</form>

    <p><a href="photoupload.php">Photo Uploader</a></p>
</body>
</html>
