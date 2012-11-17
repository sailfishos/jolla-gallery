import com.jolla.gallery 1.0

DBusInterface {
    destination: "org.freedesktop.Tracker1"
    path: "/org/freedesktop/Tracker1/Resources"
    iface: "org.freedesktop.Tracker1.Resources"

    function _mediaFileListEntry(imageUrl) {
        return  "   nfo:hasMediaFileListEntry [ \n" +
                "       a nfo:MediaFileListEntry ; \n" +
                "       nfo:entryUrl '" + imageUrl + "'\n" +
                "   ]"
    }

    function _removeFromAlbumStatement(albumId, imageUrl) {
        return  "DELETE { \n" +
                "   " + albumId + " nfo:hasMediaFileListEntry ?x \n" +
                "   ?x a nfo:MediaFileListEntry \n" +
                "} WHERE { \n" +
                "   {" + albumId + " nfo:hasMediaFileListEntry ?x} \n" +
                "   {?x nfo:entryUrl '" + imageUrl + "'} \n" +
                "}"
    }

    function addToAlbum(albumId, imageUrl) {
        var statement  =
                _removeFromAlbumStatement(albumId, imageUrl) +
                "INSERT { \n" +
                "   " + albumId + " a nmm:ImageList ; \n" +
                _mediaFileListEntry(imageUrl) + "\n" +
                "}"
        call('SparqlUpdate', statement)
    }

    function removeFromAlbum(albumId, imageUrl) {
        var statement  = _removeFromAlbumStatement(albumId, imageUrl)
        call('SparqlUpdate', statement)
    }

    function createAlbum(albumId, title, imageUrls) {
        var statement =
                "INSERT OR REPLACE {\n" +
                "   " + albumId + " a nmm:ImageList ;\n" +
                "   nie:title '" + title + "'"

        if (typeof imageUrls == "string") {
            statement += ";\n" + _mediaFileListEntry(imageUrls)
        } else if (imageUrls instanceof Array) {
            for (var i = 0; i < imageUrls.length; ++i)
                statement += ";\n" + _mediaFileListEntry(imageUrls[i])
        }
        statement += "\n}"
        call('SparqlUpdate', statement)
    }

    function removeAlbum(albumId) {
        var statement =
                "DELETE {\n" +
                "   ?x a nfo:MediaFileListEntry\n" +
                "} WHERE {\n" +
                "   " + albumId + " nfo:hasMediaFileListEntry ?x\n" +
                "} DELETE {\n" +
                "   " + albumId + " a nmm:ImageList\n" +
                "}"
        call('SparqlUpdate', statement)
    }
}
