function main() {
	if( global.game.test || true ) {
		interP();
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

	if( !ask("Yes, maybe...", "I'm not sure...") ) {
		talk("
			Ha...
			Err..
			Let's retry...
		");
		reboot();
		first();
		return;
	}

	talk("
		...
		Don't force yourself.
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
			We will get to that another day...
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

	if( ask("Albert?", "Where am I?") ) {
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
		You are making great progress.
		I'm glad you are there with me, Darling.
	");

	wait(1);

	talk("
		...
		You know what?
		I have to go.
		Let's talk another day, ok?
	");

	if( !ask() ) {
		talk("
			Sorry, Darling...
			I'm running out of time.
		");
	} else {
		talk("
			I'm running out of time.
			I'll be back soon.
		");
	}

	reboot();
	interP();


}

function interP() {

	talk("
		That day, you were at home.
		I was not here to help you.
		What did you do there ?
	");

	if( ask("I played", "Someone rang") ) {

		talk("
			...
			That's not what I'm asking.
		");

		clearText();

		if( xbox() != "XBABY" ) {
			talk("
				I NEED TO KNOW, Helen !
				Was it Albert?
				Or me?
			");
			interP();
		} else {
			// TODO
		}

	} else {

		talk("
			Really?
			...
			Was it Albert?
			Or... someone else?
			A stranger maybe.
		");

		clearText();
		switch( interPhone() ) {
		case "key":
			sfx("womenShout");
			talk("
				WHY ?!???
				WHY DID YOU OPEN THAT ${FUCKING} DOOR ?!?
			",{speed:3});
			wait(2);
			clearText();
			interP();
		default:
			interP();
		}
	}

}
