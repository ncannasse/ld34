function main() {

	talk("
		Oh ! Darling !
		Can you hear me ?
		I was so worried !
		Do you remember anything ?
	");

	if( ask("Yes, maybe...", "I'm not sure...") ) {
		talk("
			Ha...
			Err..
			We haven't even started yet...
		");
		reboot();
	}

	talk("
		Don't worry!
		It's alright!
		We'll get you back on your feet quickly.
	");

	who();
}


function who() {

	if( ask("Who are you?", "Who am I?") ) {
		talk("
			Oh !
			Of course.
			You want to know...
			...
			I'm ${Heinsenberg}.
		");
		if( !has("names") ) {
			talk("
				But don't try too hard remembering it for now!
				We will need you to go through several steps before that...
			");
			who();
			return;
		} else {
			throw "TODO";
		}
	} else {

	}

}