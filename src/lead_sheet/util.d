module lead_sheet.util;

import std.file;
import std.path;


void foreachLeadsheet(void delegate(string fileName, string fileContents) f){
	const string RUNNING_DIR = dirName(thisExePath());
	const string LEAD_SHEET_SOURCE_DIR = buildPath(RUNNING_DIR, "..","leadsheets_raw");

	foreach(string fileName; dirEntries(LEAD_SHEET_SOURCE_DIR, SpanMode.shallow, false)){
		string fileContents = readText(fileName);
		f(fileName, fileContents);
	}
}