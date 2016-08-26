module lead_sheet.categorizer;

import std.stdio;
import std.regex;
import std.typecons : tuple, Tuple;
import std.algorithm.sorting;
import std.algorithm;
import std.array;
import lead_sheet.util;


void analyzeSongsForCategory(Regex!char matchAttribute, Regex!char cleanAttribute){
	uint[string] songCategoryCountedSet;
	uint uncategorizedCount = 0;

	foreachLeadsheet(delegate void(string fileName, string fileContents){
		auto categoryMatch = matchFirst(fileContents, matchAttribute);
		if(!categoryMatch.empty){
			string category = replaceFirst(categoryMatch.hit, cleanAttribute, "");
			if(category in songCategoryCountedSet){
				songCategoryCountedSet[category]++;
			}
			else{
				songCategoryCountedSet[category] = 1;
			}
		}
		else{
			//writeln("No category detected for: ", fileName);
			uncategorizedCount++;
		}
	});
	writeln("Uncategorized songs: ", uncategorizedCount);
	Tuple!(string, uint)[] pairs;
	writeln(songCategoryCountedSet.length, " unique categories found");
	foreach(pair;songCategoryCountedSet.byPair){
		pairs ~= pair;
	}
	//sort(pairs);
	sort!("a[1] > b[1]", SwapStrategy.stable)(pairs);
	foreach(pair;pairs){
		writeln(pair[0], " has ", pair[1], " entries");
	}
}


