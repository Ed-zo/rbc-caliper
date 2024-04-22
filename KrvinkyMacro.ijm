realSizeWidth = 125.9;
realSizeHeight = 94.42;

function closeAllWindows() {
	close("*");
	selectWindow("Results");
	close("Results");
	close("ROI Manager");
}

function makro() {
	title = getTitle();
	directory = getInfo("image.directory");
	
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1.0000000");
	
	run("Scale...", "x=0.5 y=0.5 width=1632 height=1224 interpolation=Bilinear average create title=original");
	run("Duplicate...", "title=obal");
	run("8-bit");
	//run("5 ramps");
	run("Enhance Contrast...", "saturated=0.45 normalize equalize");
	run("Duplicate...", "title=jadro");
	run("Tile");
	
	selectImage("obal");
	run("Maximize");
	setAutoThreshold("Default no-reset");
	run("Threshold...");
	setThreshold(0, 152);
	setOption("BlackBackground", true);
	waitForUser("Threshold Obal");
	
	selectImage("jadro");
	run("Maximize");
	run("Threshold...");
	setThreshold(0, 45);
	setOption("BlackBackground", true);
	waitForUser("Threshold jadro");
	run("Close");
	
	selectImage("obal");
	run("Erode");
	run("Median", "radius=5");
	run("Erode");
	run("Dilate");
	run("Watershed");
	selectImage("jadro");
	run("Median", "radius=4");
	run("Dilate");
	
	selectImage("obal");
	setTool( "Paintbrush Tool" );
	run("Maximize");
	run("Add Image...", "image=original x=0 y=0 opacity=70");
	waitForUser("Fix watershed");
	run("Ellipse Split", "binary=obal add_to_manager add_to_results_table remove merge_when_relativ_overlap_larger_than_threshold overlap=44 major=30-350 minor=30-350 aspect=1-Infinity");
	
	for (i = 0; i < Table.size; i++) {
		Table.set("type", i, "1");
	}
	
	selectImage("jadro");
	run("Ellipse Split", "binary=[Use standard watershed] add_to_manager add_to_results_table merge_when_relativ_overlap_larger_than_threshold overlap=34 major=25-100 minor=25-100 aspect=1-Infinity");
	run("Add Image...", "image=original x=0 y=0 opacity=90");
	
	selectImage("original");
	run("Close");
	
	selectImage("obal");
	close();
	
	selectImage(title);
	close();
	
	selectImage("jadro");
	run("Scale to Fit");
	
	ok = getBoolean("Is it ok?");
	if (ok) {
		Table.save(directory + title + ".csv");
		closeAllWindows();
		close("*");
		close("ROI Manager");
		exec("py", "data_processing.py", directory + title);
	} else {
		closeAllWindows();
		open(directory + title);
		makro();
	}
}

macro "Meranie krviniek [k]" {
	makro();
}