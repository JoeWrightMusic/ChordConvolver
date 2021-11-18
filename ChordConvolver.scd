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
	sig = BlitB3Square.ar(freq)*0.1;
	sig = Resonz.ar(sig, freq, 1);
	sig = sig*env;
	Out.ar(0, sig!2);
}).add;

//__________________Play Chords
t = Task{
	"".postln;
	"____________________".postln;
	~lastProcess.postln;
	"____________________".postln;

	"CHORD A:".postln;
	for(0, a.size-1, {
		|i|
		a[i].post;
		if(a[i]%1>0,{"".post}, {".00".post});
		"\t".post;
		"(".post;
		a[i].floor(1).midinote.post;
		if(a[i]%1>0,{" + 1/4tone)".postln}, {")".postln});
		Synth(\playTone, [\freq, a[i].midicps]);
		0.15.wait;
	});
	3.5.wait;
	"".postln;
	"CHORD B:".postln;
	for(0, b.size-1, {
		|i|
		b[i].post;
		if(b[i]%1>0,{"".post}, {".00".post});
		"\t".post;
		"(".post;
		b[i].floor(1).midinote.post;
		if(b[i]%1>0,{" + 1/4tone)".postln}, {")".postln});
		Synth(\playTone, [\freq, b[i].midicps]);
		0.15.wait;
	});
	3.5.wait;
	"".postln;
	"OUTPUT:".postln;
	for(0, x.size-1, {
		|i|
		x[i].post;
		if(x[i]%1>0,{"".post}, {".00".post});
		"\t".post;
		"(".post;
		x[i].floor(1).midinote.post;
		if(x[i]%1>0,{" + 1/4tone)".postln}, {")".postln});
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
		tempNote = (a.wrapAt(i)*b.wrapAt(i)) % 12;
		//round to nearest 1/4 tone
		tempNote = tempNote.round(0.5);
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
	~lastProcess="MULTIPLY";
};

//__________________Divide
~aDividesB = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the note of chord a divided by the note from b%12 to nearest 1/4t
		tempNote = (b.wrapAt(i)/(c.wrapAt(i)[1])).round(0.5);
		//remove surplus 8ves & round to nearest 1/4t
		tempNote = (tempNote/12).round(0.5);
		//get the lowest 8ve from a & b at current index
		if(d.wrapAt(i)[1]<=c.wrapAt(i)[1], {temp8ve=d.wrapAt(i)[1]}, {temp8ve=c.wrapAt(i)[1]});
		//get the range between those 8ves / 2
		span8ves = (d.wrapAt(i)[1] - c.wrapAt(i)[1]).abs;
		//find the mid-point 8ve between a&b
		if(span8ves>0, {
			span8ves=(span8ves*0.5).round(1);
			temp8ve = temp8ve+span8ves;
			});
		//transfer result to output array, x
		x[i] = tempNote+(12*temp8ve);
	});
	~lastProcess="A DIVIDES B";
};
~bDividesA = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the note of chord a divided by the note from b%12 to nearest 1/4t
		tempNote = (a.wrapAt(i)/(d.wrapAt(i)[1])).round(0.5);
		//remove surplus 8ves & round to nearest 1/4t
		tempNote = (tempNote/12).round(0.5);
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
	~lastProcess="B DIVIDES A";
};

//__________________Addition
~addition = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the added note %12
		tempNote = (a.wrapAt(i) + b.wrapAt(i)) % 12;
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
	~lastProcess="ADDITION";
};

//__________________Subtraction
~aSubtractB = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the subtracted note %12
		tempNote = (a.wrapAt(i) - b.wrapAt(i)) % 12;
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
	~lastProcess="A SUBTRACTS B";
};
~bSubtractA = Task{
	var len, tempNote, temp8ve, span8ves;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);

	for(0, len-1, {
		|i|
		//get the subtracted note %12
		tempNote = (b.wrapAt(i) - a.wrapAt(i)) % 12;
		//get the lowest 8ve from a & b at current index
		if(d.wrapAt(i)[1]<=c.wrapAt(i)[1], {temp8ve=d.wrapAt(i)[1]}, {temp8ve=c.wrapAt(i)[1]});
		//get the range between those 8ves / 2
		span8ves = (d.wrapAt(i)[1] - c.wrapAt(i)[1]).abs;
		//find the mid-point 8ve between a&b
		if(span8ves>0, {
			span8ves=(span8ves*0.5).round(1);
			temp8ve = temp8ve+span8ves;
			});
		//transfer result to output array, x
		x[i] = tempNote+(12*temp8ve);
	});
	~lastProcess="B SUBTRACTS A";
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
		tempNote = tempNote.round(0.5);
		//transfer result to output array, x
		x[i] = tempNote;
	});
	~lastProcess="SHADOW";
};

//__________________Mirrors
~a_mirrorsB = Task{
	var axis, diff, tempNote;
	//calculate the axis for reflection
	axis = a.mean;
	//create a new array with b.size number of items
	x = Array.newClear(b.size);
	//reflect items of b around the axis
	for(0, b.size-1, {
		|i|
		//calculate distance from axis to b[i]
		diff = b[i]-axis;
		//calculate mirror note around axis
		tempNote = axis + (-1 * diff);
		//transfer result to output array, x
		x[i] = tempNote;
	});
	~lastProcess="A MIRRORS B";
};
~b_mirrorsA = Task{
	var axis, diff, tempNote;
	//calculate the axis for reflection
	axis = b.mean;
	//create a new array with b.size number of items
	x = Array.newClear(a.size);
	//reflect items of b around the axis
	for(0, a.size-1, {
		|i|
		//calculate distance from axis to b[i]
		diff = a[i]-axis;
		//calculate mirror note around axis
		tempNote = axis + (-1 * diff);
		//transfer result to output array, x
		x[i] = tempNote;
	});
	~lastProcess="B MIRRORS A";
};

//__________________Mid Point
~midPoint = Task{
	var len, tempNote;
	//get the length of the longer chord list
	if(a.size>=b.size, {len=a.size}, {len=b.size});
	//create array, x, that is the the same size as the longer chord list
	x = Array.newClear(len);
	//get mid points
	for(0, len-1, {
		|i|
		//calculate mid point between notes
		tempNote = a.wrapAt(i)+b.wrapAt(i)*0.5;
		//round to nearest 1/4t
		tempNote = tempNote.round(0.5);
		//transfer result to output array, x
		x[i] = tempNote;
	});
	~lastProcess="MID POINT";
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
*
* STEP 2 - CHOOSE A CHORD FUNCTION & GENERATE A NEW CHORD
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
~aDividesB.reset.play //excecute this line with cmd+enter (mac) or ctl+enter (win)
~bDividesA.reset.play //excecute this line with cmd+enter (mac) or ctl+enter (win)
/* Divides corresponding notes in each chord by taking the midi value from the 1st chord and dividing by
*  2ndChord%12. the result is then transposed back to the original register of a&b.If the note-pairs are in
*  different octaves, the midpoint rounded to the nearest 8ve is used.
*/

// ADDITION
~addition.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)
/* Adds corresponding notes in each chord. The two notes are summed and then transposed back down
*  in 8ves to match the original octave of the input notes. If the note-pairs are in different
*  octaves, the midpoint rounded to the nearest 8ve is used.
*/

// SUBTRACTION
~aSubtractB.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)
~bSubtractA.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)
/* Subtracts corresponding notes in each chord. 1st chord Note is subtracted from 2nd chord note, and then
*  transposed back in 8ves to match the original octave of the input notes. If the note-pairs are in different
*  octaves, the midpoint rounded to the nearest 8ve is used.
*/

// SHADOW
~shadow.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)
/* Adds together chord lists a & b and then creates a new chord from the mid-points (shadows) between those notes.
*
*/

// A MIRRORS B
~a_mirrorsB.reset.play;
~b_mirrorsA.reset.play;
/* A reflection point is calculated from the mean point of one chord, and used to reflect all the items in the other
*  about that mean point.
*/

// MID POINT
~midPoint.reset.play;
/* Creates an output chord where each note is the mid-point between the two corresponding notes from chords a + b
*
*/
//====================================================================


/*
  _____ _______ ______ _____    ____
 / ____|__   __|  ____|  __ \  |___ \
| (___    | |  | |__  | |__) |   __) |
 \___ \   | |  |  __| |  ___/   |__ <
 ____) |  | |  | |____| |       ___) |
|_____/   |_|  |______|_|      |____/
*
* STEP 3 - LISTEN BACK / PRINT OUTPUT
*          By default, the notes of the output chord are left in the order they're generated. This can mean that -
*          for certain functions and for input chords of different lengths - the resulting output may not be in
*          order of low-high pitched tones. To fix this, excecute the "x.sort" line first, and then play the output.
*/
x.sort //if needed, excecute this line with cmd+enter (mac) or ctl+enter (win)
//PLAY & PRINT OUTPUT
t.reset.play; //excecute this line with cmd+enter (mac) or ctl+enter (win)



