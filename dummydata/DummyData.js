var thumbnails = [
            "007a7801015bbd0424b368920cc8f23c.jpeg",  "04de834314def371d74ceb9ba3fa844b.jpeg",  "093b0aa46fcfd30ab8805e4cf02c539b.jpeg",
            "01d90245f044ca1a8fb1edefb143cbd4.jpeg",  "05347beb8f7ac92defd91f4fb0a9a502.jpeg",  "09f6ef478f4b5c67a95303fd93bc5d6c.jpeg",
            "02068d3aaf3edbb87fea739c1226a111.jpeg",  "05c6f905024351cbd1a69194574697bc.jpeg",  "0ae7a6690eb15f437a2e1bdc4a5b86e4.jpeg",
            "02ca931bf193c467fd5ad886c6e5d2d5.jpeg",  "05ea73cead9f384a9d8e93788d92f2cd.jpeg",  "0af11367508bf9fb54f9f44c3855f5fa.jpeg",
            "02ecbc3067395380c08202dce916de49.jpeg",  "06bb9289176926b158e069e805349c56.jpeg",  "0cd823bc81bae997fcb6df0a2a815b00.jpeg",
            "039d18e616f7b5e56cc71d9a415e860d.jpeg",  "08775b41a629e3cc8007f914eedb7057.jpeg",  "0f5ca5b80deb296cf4ff3835e32e2ecc.jpeg",
            "0428c2f656df620f1f8a52f626cc8ddd.jpeg",  "08ded73f135614d62f6d985385e0d62d.jpeg",  "0fc9ff0ee7c6901741194e7fca880308.jpeg"
        ]


var fullSizeImages = [
            "12090002.jpg",  "12090009.jpg",  "12090011.jpg",  "12090023.jpg",  "12090092.jpg",  "12090119.jpg",
            "12090005.jpg",  "12090010.jpg",  "12090018.jpg",  "12090067.jpg",  "12090118.jpg"
           ]

function populateThumbnails(model, count) {

    var thumbs = []
    for (var index = 0; index < count; index++){
        var thumbUrl = "../dummydata/thumbs/"+thumbnails[Math.floor(Math.random()*thumbnails.length)]
        var fullsizeUrl = "../dummydata/images/"+fullSizeImages[Math.floor(Math.random()*fullSizeImages.length)]
        model.append({
                         "thumbnail": thumbUrl,
                         "fullsize" : fullsizeUrl
                     })        
    }

}
