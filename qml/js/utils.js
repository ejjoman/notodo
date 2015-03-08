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

String.prototype.endsWith = function(suffix) {
    return this.indexOf(suffix, this.length - suffix.length) !== -1;
};

function serialize(object, maxDepth) {
    function _processObject(object, maxDepth, level) {
        var output = Array()
        var pad = " "
        if (maxDepth == undefined) {
            maxDepth = -1
        }
        if (level == undefined) {
            level = 0
        }
        var padding = Array(level + 1).join(pad)
        output.push((Array.isArray(object) ? "[" : "{"))
        var fields = Array()
        for (var key in object) {
            var keyText = Array.isArray(object) ? "" : ("\"" + key + "\": ")
            if (typeof (object[key]) == "object" && key != "parent" && maxDepth != 0) {
                var res = _processObject(object[key], maxDepth > 0 ? maxDepth - 1 : -1, level + 1)
                fields.push(padding + pad + keyText + res)
            } else {
                fields.push(padding + pad + keyText + "\"" + object[key] + "\"")
            }
        }
        output.push(fields.join(",\n"))
        output.push(padding + (Array.isArray(object) ? "]" : "}"))
        return output.join("\n")
    }
    return _processObject(object, maxDepth)
}
