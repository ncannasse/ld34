function main() {
	if( global.game.test ) {
		xboxDone();
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
		Now that you remember Albert,
		Do you think we can talk about you?
	");

	while( true ) {
		if( ask() ) break;
		talk("
			...
			Come on, Helen.
			Don't be a child.
			Let's talk about you.
		");
	}

	talk("Good.");

	clearText();

	talk("
		I don't think that you remember a lot of things.
		...
		You got into... an accident.
		You were no longer with us for some time.
	");
	wait();
	talk("
		...
		I was very sad.
		We didn't have kids, but they were sad too.
	");
	questions();
}

var qKids = false;
var qAccident = false;

function questions() {

	if( !qKids || !qAccident ) {

		if( ask("Kids?", "Accident?") ) {
			qKids = true;

			talk("
				...
				Albert.
				He was my good friend.
				Yours too.
				He's not a kid, you know ?
				...
			");

			async(shake());
			talk("I'LL ${FUCKING} KILL HIM!!!", { speed:5 } );
			clearText();
			talk("
				I like Albert.
				You too, right?
			");

		} else {
			qAccident = true;

			talk("
				...
				I'm not sure what happened.
				I was not there.
				...
				I'll ask you about it later.
			");
			clearText();

			if( !qKids )
				talk("
					Anything else?
				");

		}
		questions();
		return;
	}

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
		That day.
		The accident day, you were at home.
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
			wait();
			clearText();
			interP();
		} else {
			xboxDone();
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
			async(shake(1,2));
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

function xboxDone() {

	talk("
		So...
		That day.
		Someone came in.
		And you opened the door.
	");

	while( !ask() ) {
		talk("
			...
			Yes you did.
		");
	}

	talk("...");

	sfx("womenShout");
	async(shake());
	talk("WHY DID YOU OPEN THAT ${FUCKING} DOOR ?!?",{speed:3});
	clearText();

	talk("
		I understand.
		That was an accident.
		Alfred's fault.
		...
		Not yours.
		...
		But I didn't know.
		...
		IT WAS A MISUNDERSTANDING.
	");

}