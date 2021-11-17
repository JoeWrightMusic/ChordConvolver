/*
  _____ _    _  ____  _____  _____     _____ ____  _   ___      ______  _ __      ________ _____
 / ____| |  | |/ __ \|  __ \|  __ \   / ____/ __ \| \ | \ \    / / __ \| |\ \    / /  ____|  __ \
| |    | |__| | |  | | |__) | |  | | | |   | |  | |  \| |\ \  / / |  | | | \ \  / /| |__  | |__) |
| |    |  __  | |  | |  _  /| |  | | | |   | |  | | . ` | \ \/ /| |  | | |  \ \/ / |  __| |  _  /
| |____| |  | | |__| | | \ \| |__| | | |___| |__| | |\  |  \  / | |__| | |___\  /  | |____| | \ \
 \_____|_|  |_|\____/|_|  \_\_____/   \_____\____/|_| \_|   \/   \____/|______\/   |______|_|  \_\

*  A set of functions for generating a new set of pitches from
*  two given chords.
*  Created by Joe Wright for Edmund Hunt / the Augmented Reality project at
*  Royal Birmingham Conservatoire, UK, 2021
*/
//==============================================================


/*
  _____ _______ ______ _____    __
 / ____|__   __|  ____|  __ \  /_ |
| (___    | |  | |__  | |__) |  | |
 \___ \   | |  |  __| |  ___/   | |
 ____) |  | |  | |____| |       | |
|_____/   |_|  |______|_|       |_|
*/

(//STEP 1 - DEFINE SYNTHS & TASKS
//1A -> WRITE YOUR MIDI CHORDS INTO THE ARRAYS (a&b) BELOW,
//      OVERWRITE/EXTEND THE LISTS AS NEEDED
a = [60, 62.75, 78, 80, 90.25, 100.5];//Input Chord 1
b = [42, 47.75, 49, 51.25, 71.25];//Input Chord 2

//1B -> THEN EXCECUTE THE CODE BLOCK
//      (click on this line then hit cmd+enter (mac) or ctl+enter (win)
//      NOW SCROLL DOWN TO STEP 2




//will store a&b as note-8ve pairs
c = Array.fill2D(a.size, 2, {0});
d = Array.fill2D(b.size, 2, {0});

//__________________Convert a&b to note-8ve pairs
for(0, a.size-1, {
	arg i;
	c[i][1]= (a[i]/12).floor(1);
	c[i][0]= a[i]%12;
});
for(0, b.size-1, {
	arg i;
	d[i][1]= (b[i]/12).floor(1);
	d[i][0]= b[i]%12;
});

//__________________Synth
SynthDef(\playTone,{
	arg freq;
	var sig, env;
	env = EnvGen.kr(Env.linen(0.1, 3, 1), doneAction:2);
	sig = DPW3Tri.ar(freq)*0.1;
	sig = sig*env;
	Out.ar(0, sig!2);
}).add;

//__________________Play Chords
t = Task{
	"".postln;
	"____________________".postln;
	"CHORD A:".postln;
	for(0, a.size-1, {
		|i|
		a[i].postln;
		Synth(\playTone, [\freq, a[i].midicps]);
		0.15.wait;
	});
	3.5.wait;
	"".postln;
	"CHORD B:".postln;
	for(0, b.size-1, {
		|i|
		b[i].postln;
		Synth(\playTone, [\freq, b[i].midicps]);
		0.15.wait;
	});
	3.5.wait;
	"".postln;
	"OUTPUT:".postln;
	for(0, x.size-1, {
		|i|
		x[i].postln;
		Synth(\playTone, [\freq,x[i].midicps]);
		0.15.wait;
	});
	"____________________".postln;
	"".postln;
};
//__________________Multiply
~multiply = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the multiplied note %12
		tempNote = (a.wrapAt(i)*b.wrapAt(i))%12;
		//round to nearest 1/4 tone
		tempNote = tempNote.round(0.25);
		//get the lowest 8ve from a & b at current index
		if(c.wrapAt(i)[1]<=d.wrapAt(i)[1], {temp8ve=c.wrapAt(i)[1]}, {temp8ve=d.wrapAt(i)[1]});
		//get the range between those 8ves / 2
		span8ves = (c.wrapAt(i)[1] - d.wrapAt(i)[1]).abs;
		//find the mid-point 8ve between a&b
		if(span8ves>0, {
			span8ves=(span8ves*0.5).round(1);
			temp8ve = temp8ve+span8ves;
			});
		//transfer result to output array, x
		x[i] = tempNote+(12*temp8ve);
	});
};

//__________________Divide
~divide = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the note of chord a divided by the note from b%12 to nearest 1/4t
		tempNote = (a.wrapAt(i)/(d.wrapAt(i)[1])).round(0.25);
		//remove surplus 8ves
		tempNote = tempNote/12;
		//get the lowest 8ve from a & b at current index
		if(c.wrapAt(i)[1]<=d.wrapAt(i)[1], {temp8ve=c.wrapAt(i)[1]}, {temp8ve=d.wrapAt(i)[1]});
		//get the range between those 8ves / 2
		span8ves = (c.wrapAt(i)[1] - d.wrapAt(i)[1]).abs;
		//find the mid-point 8ve between a&b
		if(span8ves>0, {
			span8ves=(span8ves*0.5).round(1);
			temp8ve = temp8ve+span8ves;
			});
		//transfer result to output array, x
		x[i] = tempNote+(12*temp8ve);
	});
};

//__________________Shadow
~shadow = Task{
	var ab, tempNote;
	//create new array with an arbitrary max size
	ab = a++b;
	//sort the concatenated ab array
	ab.sort;
	//create an output array with 1 less value than ab
	x = Array.newClear(ab.size-1);
	//calculate the midpoint (shadow) tone between all
	//elements in ab
	for(0, x.size-1, {
		|i|
		//get mid point between two notes in ab
		tempNote = ab[i] + ( (ab[i+1]-ab[i])*0.5 );
		//round to nearest 1/4t
		tempNote = tempNote.round(0.25);
		//transfer result to output array, x
		x[i] = tempNote;
	});
};

s.boot;
)
//====================================================================


/*
  _____ _______ ______ _____    ___
 / ____|__   __|  ____|  __ \  |__ \
| (___    | |  | |__  | |__) |    ) |
 \___ \   | |  |  __| |  ___/    / /
 ____) |  | |  | |____| |       / /_
|_____/   |_|  |______|_|      |____|
*/
/* STEP 2 - CHOOSE A CHORD FUNCTION & GENERATE A NEW CHORD
*           (excecute one line below - cmd+enter/ctl+enter - with your desired function)
*           all functions wrap the shorter chord list (a or b) to generate a full
*           list of output chords. You can re-run this step as many times as you like
*           without needing to re-run step 1
*/

// MULTIPLY
~multiply.reset.play; // excecute this line with cmd+enter (mac) or ctl+enter (win)
/* Multiplies corresponding notes in each chord. The two notes
*  are multiplied and then transposed back down in 8ves to match the original
*  octave of the input notes. If the note-pairs are in different octaves, the
*  midpoint rounded to the nearest 8ve is used.
*/

// DIVIDE
~divide.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)
/* Divides corresponding notes in each chord by taking the midi value from a and dividing by b%12. *  the result is then transposed back to the original register of a&b.If the note-pairs are in *    *  different octaves, the midpoint rounded to the nearest 8ve is used.
*/

// SHADOW
~shadow.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)



// shadow
// add
// mirror / inverse
//====================================================================


/*
  _____ _______ ______ _____    ____
 / ____|__   __|  ____|  __ \  |___ \
| (___    | |  | |__  | |__) |   __) |
 \___ \   | |  |  __| |  ___/   |__ <
 ____) |  | |  | |____| |       ___) |
|_____/   |_|  |______|_|      |____/
*/

x.sort
//PLAY OUTPUT
t.reset.play;
