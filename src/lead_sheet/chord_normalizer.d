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
	auto inRegex = regex(r"^[\d*]?[A-Ga-g]");
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
	chord = replaceFirst(chord, regex(r"^[\d*]"), "");
	int chordNum = noteMap[toUpper(chord[0])];
	if(chord.length >= 2){
		if(chord[1] == '-'){
			chordNum--;
		}
		else if(chord[1] == '#'){
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
unittest{
	assert(noteFromNum(0) == "C");
	assert(noteFromNum(-1) == "B");
	assert(noteFromNum(13) == "D-");
}

string transposedChord(string originalChord, int keyBase)
in{
	assert(keyBase >= 0);
	assert(keyBase < 12);
}
body{
	if(keyBase == 0){
		return originalChord;
	}
	int chordNum = chordToNoteNum(originalChord);
	//transpose chord to C major
	int normalizedChordNum = normalizeBase12(chordNum - keyBase);
	//string transposedChord = to!string(originalChord[0]);
	auto chordTypeRegex = regex(r"^\d[A-Ga-g][-#]?");
	auto slashChordRegex = regex(r"/[A-Ga-g][-#]?$");
	string transposedChord = to!string(originalChord[0]) ~ noteFromNum(normalizedChordNum) ~ replaceFirst(originalChord, chordTypeRegex, "");

	//transpose root for slash chords
	auto slashChordMatch = matchFirst(transposedChord, slashChordRegex);
	if(!slashChordMatch.empty){
		string slashChord = removechars(slashChordMatch.hit, "/");
		string transposedSlashChord = transposeChord(slashChord, keyBase);
		transposedChord = replaceFirst(transposedChord, slashChordRegex, "/" ~ transposedSlashChord);
	}
	
	return transposedChord;
}
unittest{
	assert(transposedChord("1D7b9/F#", 0) == "1D7b9/F#");
	assert(transposedChord("1D7b9/F#", 7) == "1G7b9/B");
	assert(transposedChord("2B/B-", 10) == "2D-/C");
}

//transposes bass note for slash chords
string transposeChord(string originalChord, int keyBase)
body{
	if(keyBase == 0){
		return originalChord;
	}
	int chordNum = chordToNoteNum(originalChord);
	int normalizedChordNum = normalizeBase12(chordNum - keyBase);
	return noteFromNum(normalizedChordNum);
}
unittest{
	assert(transposeChord("C", 0) == "C");
	assert(transposeChord("C", 2) == "B-");
	assert(transposeChord("D", 3) == "B");
}

void normalizeLeadSheetChords(string leadSheetRaw){
	//strip metadata and blank lines
	string cleanedLeadSheet = replaceAll(leadSheetRaw, regex(r"^!+.*|^\*\*+.*|^\s*$", "m"), "");
	string[] lines = splitLines(cleanedLeadSheet);
	//ignore empty lines
	auto emptyLinesRegex = regex(r"^\s*$");
	auto chordRegex = regex(r"^\d[A-G]");
	auto keyRegex = regex(r"^\*[A-Ga-g][-#]?:$");
	auto majorKeyRegex = regex(r"[A-G]");
	auto alternateChordRegex = regex(r"\(.+\)$");
	int keyBase = 0;
	foreach(string line;lines){
		//blank lines
		if(!matchFirst(line, emptyLinesRegex).empty){
			continue;
		}
		//key signature
		else if(!matchFirst(line, keyRegex).empty){
			keyBase = chordToNoteNum(line);
			//transpose key to C major or c minor
			if(!matchFirst(line, majorKeyRegex).empty){
				line = "*C:";
			}
			//minor
			else{
				line = "*c:";
			}

		}
		//chord
		else if(!matchFirst(line, chordRegex).empty){
			//remove alternate chord(s)
			line = replaceFirst(line, alternateChordRegex, "");
			line = transposedChord(line, keyBase);
		}
		writeln(line);
	}
	//print empty line between lead sheets
	writeln("");
}

void normalizeLeadSheets(){
	foreachLeadsheet(delegate void(string fileName, string fileContents){
		normalizeLeadSheetChords(fileContents);
	});
}