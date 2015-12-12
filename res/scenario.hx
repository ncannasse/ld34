function main() {
	if( global.game.test ) {
		codeOk();
		return;
	}
	first();
}

function first() {
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
		first();
		return;
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
		talk("
			But don't try too hard remembering it for now!
			You will need several steps before that...
		");
		who();
		return;

	}

	talk("
		...
		You're Helen.
		How do you feel, Helen ?
	");

	if( ask("Well", "Not Well") ) {
		talk("
			...
			Good !
			I'm glad to hear you're feeling well.
		");
	} else {
		talk("
			...
			It will get better soon.
			Don't worry.
		");
	}

	talk("
		I have been so much worried about you.
		You can't even imagine.
		...
		Albert was also worried.
	");

	where();
}

function neon() {
	findImage("neon",1.5, 515, 350, 50, 22);
	talk("
		${642#}?
		That was Albert code, indeed.
	");
}

function where() {

	if( ask("Albert?", "Where am I") ) {
		talk("
			You remember Albert ?
			That's suprising...
			What makes you remember him ?
		");
		neon();
		where();
		return;
	}

	train();

}

function train(?again) {

	if( again )
		talk("Hi, Helen!");

	talk("
		You're in my lab.
		I'll need you to make some... training.
		So you can recover.
		Are you ready?
	");

	if( !ask() ) {
		talk("
			...
			It's ok.
			I'll wait.
		");
		reboot();
		train(true);
		return;
	}

	talk("
		Let's get started.
	");

	if( inputCode() != "642#" ) {
		talk("
			You don't know the code?
			That was from someone you knew.
		");
		where();
		return;
	}

	codeOk();

}

function codeOk() {

	talk("
		Helen, I'm proud of you!
		You are making great progresses.
		I'm glad you are there with me, Darling.
	");

}
