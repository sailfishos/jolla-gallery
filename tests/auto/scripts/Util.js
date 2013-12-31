.pragma library

function printChildren(item, depth)
{
    if (item.hasOwnProperty("children")) {
        for (var i = 0; i < item.children.length; ++i) {
            var space = function() {
                var str = ""
                for (var i = 0; i < depth; ++i)
                    str += "-"
                return str + " "
            }()
            console.log(space + "child: "  + item.children[i])
            printChildren(item.children[i], depth + 1)
        }
    }
}

function findItem(item, isItem) {
    if (isItem(item)) {
        return item
    }

    if (!item.hasOwnProperty("children")) {
        return null
    }

    for (var i = 0; i < item.children.length; ++i) {
        var child = findItem(item.children[i], isItem)
        if (child !== null) {
            return child
        }
    }

    return null
}

function findItemByName(item, name) {
    return findItem(item, function (item) { return item.objectName == name })
}
