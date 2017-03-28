import std.regex;
import std.stdio;
import lead_sheet.categorizer;
import lead_sheet.chord_normalizer;


void main(){
	/*Analyze for song form*/
	//auto songFormRegex = regex(r"\*>\[[^\]]+\]");
	//auto songFormFormatRegex = regex(r"^\*>");
	//analyzeSongsForCategory(songFormRegex, songFormFormatRegex);


	/*analyze for key signature*/
	//auto keySignatureRegex = regex(r"^\*[A-Ga-g].*:$", "m");
	//auto keySignatureFormatRegex = regex(r"^\*|:$");
	//analyzeSongsForCategory(keySignatureRegex, keySignatureFormatRegex);

	/*analyze for meter*/
	//auto meterRegex = regex(r"^\*M\d/\d$", "m");
	//auto meterFormatRegex = regex(r"^\*M");
	//analyzeSongsForCategory(meterRegex, meterFormatRegex);

	normalizeLeadSheets(SongMode.Minor);
}