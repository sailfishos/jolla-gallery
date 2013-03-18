.pragma library

function findItem(item, isItem) {
    if (isItem(item))
        return item
    for (var i = 0; i < item.children.length; ++i) {
        var child = findItem(item.children[i], isItem)
        if (child !== undefined)
            return child
    }
}

function findItemByName(item, name) {
    return findItem(item, function (item) { return item.objectName == name })
}
