tell application "Acorn"
	
	-- open up our document
	set doc to open ((path to home folder as rich text) & "Pictures:MyImage.png")
	
	-- go ahead and call auto levels (which will be applied to the first layer by default)
	tell doc
		auto levels
	end tell
	
	
	-- And from here, you can close your document with a save, or without if you are just playing around.
	-- tell doc to close with saving
	-- tell doc to close without saving
	
end tell