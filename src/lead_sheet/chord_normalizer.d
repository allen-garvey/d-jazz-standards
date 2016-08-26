/*
* Translates lead sheet's chords to key of C major or C minor
*/

module lead_sheet.chord_normalizer;

import std.stdio;
import std.regex;
import std.string;
import lead_sheet.util;


void normalizeLeadSheetChords(string leadSheetRaw){
	//strip metadata and blank lines
	string cleanedLeadSheet = replaceAll(leadSheetRaw, regex(r"^!+.*|^\*\*+.*|^\s*$", "m"), "");
	string[] lines = splitLines(cleanedLeadSheet);
	auto barlineRegex = regex(r"^=+");
	foreach(string line;lines){
		if(!matchFirst(line, barlineRegex).empty){
			continue;
		}
		writeln(line);
	}
}

void normalizeLeadSheets(){
	foreachLeadsheet(delegate void(string fileName, string fileContents){
		normalizeLeadSheetChords(fileContents);
	});
}