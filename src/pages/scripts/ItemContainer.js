
var items = new Array;


function first()
{
    return items[0]
}

function last()
{
    return items[items.length-1]
}

function itemAt(index)
{

    return items[index]
}

function addItem(item)
{
    items.push(item)
}

function prependItem(item)
{
    items.unshift(item)
}

// Make the first item last
function rotateBeginning()
{
    var first = items.shift()
    items.push(first)
}

function rotateEnd()
{
    var last = items.pop()
    items.unshift(last)
}

function alignTop(align)
{
    for (var i=0; i < items.length; i++)
        items[i].alignTop = align
}

function dumpItems()
{
    for (var i=0; i < items.length; i++)
        console.log("Item: "+ items[i].source + ", " + items[i].x)
}
