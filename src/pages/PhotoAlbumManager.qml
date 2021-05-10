import QtQuick 2.2
import org.nemomobile.dbus 2.0
import com.jolla.gallery 1.0

DBusInterface {
    property QtObject fileRemover: FileRemover { }

    service: "org.freedesktop.Tracker1"
    path: "/org/freedesktop/Tracker1/Resources"
    iface: "org.freedesktop.Tracker1.Resources"

    function _removeFromAlbumStatement(albumId, imageUrl) {
        return  "DELETE {\n" +
                "   " + albumId + " nfo:hasMediaFileListEntry ?x\n" +
                "   ?x a nfo:MediaFileListEntry\n" +
                "} WHERE {\n" +
                "   {" + albumId + " nfo:hasMediaFileListEntry ?x}\n" +
                "   {?x nfo:entryUrl '" + imageUrl + "'}\n" +
                "}"
    }

    function deleteMedia(url) {
        if (fileRemover.deleteFileSync(url)) {
            // Remove image from any albums, and from tracker itself.
            // Tracker will find out the image is deleted eventually, but
            // by removing it ourselves we cut down on the wait time.
            var statement =
                    _removeFromAlbumStatement("?y", url) +
                    " DELETE {\n" +
                    "   ?x a nfo:Media\n" +
                    "} WHERE {\n" +
                    "   {?x nie:url '" + url + "'}\n" +
                    "}"
            call('SparqlUpdate', statement)
        }
    }
}
