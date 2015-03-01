.pragma library

String.prototype.countWords = function() {
    var matches = this.match(/[A-Za-z0-9]+/g);

    if (matches)
        return matches.length;

    return 0;
}

String.prototype.countLines = function() {
    return this.getLines().length;
}

String.prototype.getLines = function() {
    return this.split('\n');
}

String.prototype.getFirstLineWithText = function() {
    var lines = this.getLines()

    for (var i=0; i<lines.length; i++)
        if (lines[i].trim() !== "")
            return lines[i];

    return '';
}
