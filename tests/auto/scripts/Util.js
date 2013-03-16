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

function printChildren(item, depth) {
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


function findChild(item, qmlType) {
    for (var i = 0; i < item.children.length; ++i) {
        if (item.children[i].toString().indexOf(qmlType) == 0)
            return item.children[i]

        var child = findChild(item.children[i], qmlType)
        if (child)
            return child
    }
}

function findChildData(item, qmlType) {
    for (var i = 0; i < item.data.length; ++i)
    {
        if (item.data[i].toString().indexOf(qmlType) == 0) {
            return item.data[i]
        }
    }
}
