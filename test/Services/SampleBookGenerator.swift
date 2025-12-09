import Foundation

class SampleBookGenerator {
    static func createSampleBookIfNeeded(in documentsDirectory: URL) {
        let sampleBookPath = documentsDirectory.appendingPathComponent("SampleBook")
        let fileManager = FileManager.default
        
        // Check if sample book already exists
        if !fileManager.fileExists(atPath: sampleBookPath.path) {
            do {
                try createSampleEPUB(at: sampleBookPath)
                print("✅ Sample book created successfully at: \(sampleBookPath.path)")
            } catch {
                print("❌ Error creating sample book: \(error)")
            }
        }
    }
    
    private static func createSampleEPUB(at basePath: URL) throws {
        let fileManager = FileManager.default
        
        // Create directory structure
        try fileManager.createDirectory(at: basePath, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: basePath.appendingPathComponent("META-INF"), withIntermediateDirectories: true)
        try fileManager.createDirectory(at: basePath.appendingPathComponent("OEBPS/Text"), withIntermediateDirectories: true)
        
        // Create mimetype
        let mimetype = "application/epub+zip"
        try mimetype.write(to: basePath.appendingPathComponent("mimetype"), atomically: true, encoding: .utf8)
        
        // Create container.xml
        let containerXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
            <rootfiles>
                <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
            </rootfiles>
        </container>
        """
        try containerXML.write(to: basePath.appendingPathComponent("META-INF/container.xml"), atomically: true, encoding: .utf8)
        
        // Create content.opf
        let contentOPF = """
        <?xml version="1.0" encoding="UTF-8"?>
        <package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="bookid">
            <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
                <dc:title>샘플 도서</dc:title>
                <dc:creator>테스트 작가</dc:creator>
                <dc:language>ko</dc:language>
                <dc:identifier id="bookid">sample-book-001</dc:identifier>
                <dc:subject>소설</dc:subject>
                <dc:subject>판타지</dc:subject>
            </metadata>
            <manifest>
                <item id="chapter1" href="Text/chapter1.xhtml" media-type="application/xhtml+xml"/>
                <item id="chapter2" href="Text/chapter2.xhtml" media-type="application/xhtml+xml"/>
                <item id="chapter3" href="Text/chapter3.xhtml" media-type="application/xhtml+xml"/>
                <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
            </manifest>
            <spine toc="ncx">
                <itemref idref="chapter1"/>
                <itemref idref="chapter2"/>
                <itemref idref="chapter3"/>
            </spine>
        </package>
        """
        try contentOPF.write(to: basePath.appendingPathComponent("OEBPS/content.opf"), atomically: true, encoding: .utf8)
        
        // Create toc.ncx
        let tocNCX = """
        <?xml version="1.0" encoding="UTF-8"?>
        <ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
            <head>
                <meta name="dtb:uid" content="sample-book-001"/>
            </head>
            <docTitle>
                <text>샘플 도서</text>
            </docTitle>
            <navMap>
                <navPoint id="chapter1" playOrder="1">
                    <navLabel><text>제1장</text></navLabel>
                    <content src="Text/chapter1.xhtml"/>
                </navPoint>
                <navPoint id="chapter2" playOrder="2">
                    <navLabel><text>제2장</text></navLabel>
                    <content src="Text/chapter2.xhtml"/>
                </navPoint>
                <navPoint id="chapter3" playOrder="3">
                    <navLabel><text>제3장</text></navLabel>
                    <content src="Text/chapter3.xhtml"/>
                </navPoint>
            </navMap>
        </ncx>
        """
        try tocNCX.write(to: basePath.appendingPathComponent("OEBPS/toc.ncx"), atomically: true, encoding: .utf8)
        
        // Create Chapter 1
        let chapter1 = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>제1장</title>
        </head>
        <body>
            <h1>제1장: 시작</h1>
            <p>오랜 시간 동안 잠들어 있던 고대의 마법이 깨어나기 시작했다. 아무도 알지 못했던 비밀이 밝혀지려 하고 있었다.</p>
            <p>주인공 리라는 작은 마을에서 평범하게 살아가고 있었다. 그러나 어느 날 아침, 이상한 꿈을 꾸고 일어났다. 꿈속에서 본 빛나는 수정은 너무나 생생했다.</p>
            <p>"이건 단순한 꿈이 아니야." 리라는 혼잣말을 했다. 그리고 그날부터 리라의 모험이 시작되었다.</p>
        </body>
        </html>
        """
        try chapter1.write(to: basePath.appendingPathComponent("OEBPS/Text/chapter1.xhtml"), atomically: true, encoding: .utf8)
        
        // Create Chapter 2
        let chapter2 = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>제2장</title>
        </head>
        <body>
            <h1>제2장: 발견</h1>
            <p>숲 깊은 곳에서 리라는 고대 유적을 발견했다. 돌기둥에 새겨진 문자들은 알 수 없는 언어로 쓰여 있었지만, 이상하게도 리라는 그 의미를 이해할 수 있었다.</p>
            <p>"선택받은 자만이 이 길을 열 수 있다." 리라는 문자를 소리 내어 읽었다. 그 순간, 땅이 흔들리기 시작했다.</p>
            <p>거대한 문이 천천히 열렸다. 그 안에서 푸른 빛이 새어 나왔다. 리라는 두려움과 설렘이 뒤섞인 감정으로 문 안을 들여다보았다.</p>
        </body>
        </html>
        """
        try chapter2.write(to: basePath.appendingPathComponent("OEBPS/Text/chapter2.xhtml"), atomically: true, encoding: .utf8)
        
        // Create Chapter 3
        let chapter3 = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <title>제3장</title>
        </head>
        <body>
            <h1>제3장: 운명의 만남</h1>
            <p>문 너머에는 놀라운 세계가 펼쳐져 있었다. 하늘을 나는 섬들, 빛나는 크리스탈 나무들, 그리고 마법으로 가득한 공기.</p>
            <p>"드디어 왔구나, 선택받은 자여." 어디선가 목소리가 들려왔다. 리라는 주위를 둘러보았지만 아무도 보이지 않았다.</p>
            <p>"두려워하지 마라. 나는 네 편이다." 그 순간, 하얀 빛이 모여 한 형체를 이루었다. 그것은 고대의 수호자였다.</p>
            <p>리라의 진정한 모험이 이제 시작되었다.</p>
        </body>
        </html>
        """
        try chapter3.write(to: basePath.appendingPathComponent("OEBPS/Text/chapter3.xhtml"), atomically: true, encoding: .utf8)
    }
}
