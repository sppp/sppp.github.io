# This awk program adds <br> to the end of each line
# unless it's inside a codeblock.
# It also converts the custom <block> tag into
# the actual HTML we want, and linkifies links
BEGIN {isCode=0}
{
    if ($0 == "<block>") {
        isCode = 1;
	printf("<pre><code class=\"block\">");
	# set the field separator before we read the next line
	# so we can read char by char
	FS = "";
        next;
    }
    
    if ($0 == "</block>") {
        isCode = 0;
	print "</code></pre>";
	# reset field separator to default before reading next line
	FS = " ";
	next;
    }

    #if the thing we're in is a code block
    if (isCode == 1) {
        if ($0 == "") {
            print "";
	    next;
        }
        # convert special html chars to web safe versions
        field = 1;
	while (field <= NF) {
            if ($field == "&") {
                printf "&amp;";
            } else if ($field == "<") {
	        printf "&lt;";
            } else if ($field == ">") {
	        printf "&gt;";
            } else if ($field == "\"") {
	        printf "&quot;";
            } else if ($field == "'") {
	        printf "&#39;";
            } else {
	        printf $field;
            }
            field++;
	    if (field > NF) {
                print "";
            }
        }
    }
    
    if (isCode == 0) {
        # if the line is empty, make it a <br> and move on
        # TODO make this write <br> even if the line has just spaces/tabs/etc.
        if ($0 == "") {
            print "<br>";
	    next;
        }
        field = 1;
        while (field <= NF) {
            if ($field ~ /^http:\/\/*/ || $field ~ /^https:\/\/*/) {
	        printf "<a href=\""$field"\">"$field"</a> ";
            } else {
                printf $field" ";
	    }
	    field++;
            # print newline if end of the line
	    if (field > NF) {
                print "<br>";
            }  
        }  
    }
}
END {}
