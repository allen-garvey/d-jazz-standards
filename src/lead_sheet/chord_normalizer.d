/*
* Translates lead sheet's chords to key of C major or C minor
*/

module lead_sheet.chord_normalizer;

import std.stdio;
import std.regex;
import std.string;
import std.math;
import std.conv;
import lead_sheet.util;

//converts int to base12
//also converts negative numbers to positive base 12
int normalizeBase12(int n)
out (result){
	assert(result >= 0);
	assert(result < 12);
}
body{
	if(n < 0){
		n = (n % 12) + 12;
	}
	return n % 12;
}
unittest{
	assert(normalizeBase12(0) == 0);
	assert(normalizeBase12(-1) == 11);
	assert(normalizeBase12(-13) == 11);
	assert(normalizeBase12(12) == 0);
	assert(normalizeBase12(13) == 1);
}

int chordToNoteNum(string chord)
in{
	auto inRegex = regex(r"^[\d*][A-Ga-g]");
	assert(!matchFirst(chord, inRegex).empty);
}
out(result){
	assert(result >= 0);
	assert(result < 12);
}
body{
	immutable int[dchar] noteMap = [
		'C' : 0,
		'D' : 2,
		'E' : 4,
		'F' : 5,
		'G' : 7,
		'A' : 9,
		'B' : 11
	];
	int chordNum = noteMap[toUpper(chord[1])];
	if(chord.length >= 3){
		if(chord[2] == '-'){
			chordNum--;
		}
		else if(chord[2] == '#'){
			chordNum++;
		}
	}
	return normalizeBase12(chordNum);
}
unittest{
	assert(chordToNoteNum("*C:") == 0);
	assert(chordToNoteNum("1C") == 0);
	assert(chordToNoteNum("1C-") == 11);
	assert(chordToNoteNum("1D") == 2);
	assert(chordToNoteNum("1D-") == 1);
	assert(chordToNoteNum("1D#") == 3);
}

string noteFromNum(int n)
body{
	immutable string[12] notes = ["C", "D-", "D", "E-", "E", "F", "G-", "G", "A-", "A", "B-", "B"];
	return notes[normalizeBase12(n)];
}

//TODO - fix slash chords
string transposedChord(string originalChord, int newChordNum)
body{
	//string transposedChord = to!string(originalChord[0]);
	auto chordTypeRegex = regex(r"^\d[A-Ga-g][-#]?");
	string transposedChord = to!string(originalChord[0]) ~ noteFromNum(newChordNum) ~ replaceFirst(originalChord, chordTypeRegex, "");
	return transposedChord;
}

void normalizeLeadSheetChords(string leadSheetRaw){
	//strip metadata and blank lines
	string cleanedLeadSheet = replaceAll(leadSheetRaw, regex(r"^!+.*|^\*\*+.*|^\s*$", "m"), "");
	string[] lines = splitLines(cleanedLeadSheet);
	auto barlineRegex = regex(r"^=+");
	auto chordRegex = regex(r"^\d[A-G]");
	auto keyRegex = regex(r"^\*[A-Ga-g][-#]?:$");
	int keyBase;
	foreach(string line;lines){
		if(!matchFirst(line, barlineRegex).empty){
			continue;
		}
		else if(!matchFirst(line, keyRegex).empty){
			keyBase = chordToNoteNum(line);
		}
		else if(!matchFirst(line, chordRegex).empty){
			int chordNum = chordToNoteNum(line);
			//transpose chord to C major
			int normalizedChordNum = normalizeBase12(chordNum - keyBase);
			line = transposedChord(line, normalizedChordNum);
		}
		writeln(line);
	}
}

void normalizeLeadSheets(){
	foreachLeadsheet(delegate void(string fileName, string fileContents){
		normalizeLeadSheetChords(fileContents);
	});
}