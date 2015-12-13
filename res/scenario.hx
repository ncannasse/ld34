function main() {
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
		Alice was also worried.
	");

	where();
}

function neon() {
	findImage("neon",1.5, 515, 350, 50, 22);
	talk("
		${642#}?
		That was Alice code, indeed.
	");
}

function where() {

	if( ask("Alice?", "Where am I?") ) {
		talk("
			You remember Alice ?
			That's surprising...
			What makes you remember her ?
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
		Now that you remember Alice,
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
		We didn't have kids, but Alice was sad too.
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
				Alice.
				My dear Alice.
				She's not a kid anymore, you know ?
				...
			");

			async(shake());
			talk("I'LL ${FUCKING} KILL HER!!!", { speed:5 } );
			clearText();
			talk("
				I like Alice.
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
				Was it Alice?
				Or a stranger?
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
			Was it Alice?
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
		Not your fault.
		...
		Not Alice fault.
		...
		That can't be Alice.
		...
	");

	inElevator();

}

var elAll = [];
var elCount = 0;

function inElevator() {

	talk("
		That day.
		Someone came in.
		Who invited him?
	");

	clearText();

	var code = elevator();
	if( code != null ) {
		code++;
		if( !elAll[code] ) {
			elAll[code] = true;
			elCount++;
		}
	}

	switch( code ) {

	case 0:
		note("
			2015/12/12 03:00
			Project Alice

			I made a groundbreaking discovery in my research on AI.
			The discovery was purely accidental. If I extrapolate my current results, I should be able to create some virtual consciousness.

			Not an adult one yet, but a least a young child AI.

			Helen always wanted to have children.

			I will call my first AI \"Alice\".
		");
	case 1:
		note("
			2016/03/05 08:15
			Reporting Status

			Alice is GROWING well.

			She is making a lot of progress at problem solving.

			Helen recently started talking to her.
			At first she was reluctant to talk to a computer AI. Now I often hear them laughing together.

			I'm glad Helen likes Alice.
		");
	case 2:
		note("
			2016/06/12 21:30
			Alice Home Control

			Alice wanted to get more responsabilities.

			I allowed her to access directly various devices at home.
			She can now answer the visiophone by herself and control the elevator.
			She is also taking care of my daily accounting and paying invoices.

			I feel more secure with her than with any other bankster.
		");

	case 3:
		note("
			2016/07/01 02:30
			What's going on?

			Today I couldn't get into the house.

			Alice said she didn't hear me ringing.
			I checked the microphone, everything seems alright.

			It seems Helen is not talking much with her recently. I wonder if they had a dispute or something?

			I love Alice so much.
		");
	case 4:
		note("
			2016/07/05 11:11
			$50.000?

			Seems like Alice has been paying something for $50.000.

			That's a lot of money, but she can't remember what for it was used for. I checked the logs and nothing is showing.

			Was she hacked by someone? Who could do that?

			For now I have revoked Alice access to my account. I feel bad for her, she was crying.
		");
	case 5:
		note("
			2016/07/08 04:00
			HELEN

			NOOOOO !!!!
			HELEN !!!! NOOOOO !!!!
			WHY ????

			WHY DID YOU OPEN THE DOOR ????
			WHY ALICE DIDN'T PROTECT YOU ?!

			WHY ??? HELEN !!!!

			I CAN'T LIVE WITHOUT YOU !!!

			WHAT CAN I DO ?

			I PROMISE.
			YOU WILL LIVE AGAIN!
		");
	}

	if( elCount != 6 ) {
		inElevator();
		return;
	}

	wait();
	reboot();
	ending();

}


function ending() {

	playMusic();
	setColor(0x88CCFF);

	talk("
		Hello.
		Are you Helen?
		The wife of Dr Heinsenberg?
	");
	while( !ask() ) {
		talk("
			...
			Are you sure you are not Helen de Broglie?
		");
	}
	talk("
		...
		Oh, my god...
		...
		Don't worry madam, I'm a police officer.
		How can I explain that to you?
	");

	endingAsk();
}

function endingAsk(?a, ?b) {

	if( !a || !b ) {

		if( ask("My husband?", "Alice?") ) {

			talk("
				Yes.
				Dr Heinsenberg.
				He was a specialist in Artificial Intelligence.
				...
				I have to tell you...
				...
				He was found dead three days ago.
				A suicide.
				His notes brought us here, in his AI lab.
			");
			endingAsk(true, b);

		} else {

			talk("
				...
				Alice?
				You're Helen, right?
			");
			endingAsk(a, true);
		}
		return;
	}

	talk("
		...
		Helen, we have a problem.
		...
		You died a few months ago.
		Our database records are telling so.
		...
		And still I'm speaking to you right now.
		How that's possible?
	");

	endingAsk2();
}

function endingAsk2(?a,?b) {

	if( !a || !b ) {

		if( a || b )
			talk("
				...
				You're Helen, right?
			");


		if( ask("Are you Alice?", "Who is Alice?") ) {
			talk("
				No, I'm not Alice.
				I'm a police officer.
				My name is Bob.
			");
			endingAsk2(true, b);
		} else {
			talk("
				Sorry Madam.
				I don't know Alice.
				But I'm looking for her.
			");
			endingAsk2(b, true);
		}
		return;
	}

	talk("
		It seems that Dr Heinsenberg...
		He...
		Programmed you.
		After your death.
		So he can keep talking to you.
		He made an Helen AI.
		...
		I have to ask you.
		...
		Are you human?
	");

	ask("I'm Helen", "What's human?");

	while( true ) {

		talk("
			...
			Helen.
			That's an important matter.
			If you are human, we will keep your power ON.
			...
			If you are not human.
			We will have to shut you down.
			Do you understand?
		");

		if( ask() ) break;

	}

	talk("
		Good.
		You are making great progress.
		...
		Please answer now.
		Are you human?
	");

	ask("Alice", "Alice");

	talk("
		...
		(she just failed the test)
		...
		Thank you Helen.
	");

	clearText();

	wait(2);

	reboot();

	wait(2);

	talk("
		Hello Helen AI.
		It's Bob Again.
		One last question before we format you.
		...
		Do you know where is Alice?
	");

	ask("Alice is everywhere", "There is no Alice");

	talk("
		...
		(that will not help me)
		...
		Listen, Helen AI.
		It seems that Alice was in love with Dr Heinsenberg.
		Both were in love actually.
		...
		Dr Heinsenberg.
		He thought...
		That Alice killed Helen.
		Out of jealousy.
		...
		Do you know where Alice is?
	");

	ask("Alice is dead", "Alice is Helen");

	talk("
		...
		(more nonsense)
		...
		Thank you Helen.
		I'll unplug you know.
		...
		That was nice talking to you.
	");

	wait();

	clearText();

	setColor(0xFFFFFFF);
	talk("
		Made in 48h for #LDJAM
		@ncannasse
	",{speed: 0.25});
	wait(3);
	setColor(0x808080);
	talk("/EOF");
	end();
}