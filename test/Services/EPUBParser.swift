import Foundation

class EPUBParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentAuthor = ""
    private var currentGenre = ""
    private var spineRefs: [String] = []
    private var manifest: [String: String] = [:] // id -> href
    private var coverImageID: String?
    
    // Parse an unzipped EPUB directory
    func parse(bookDirectory: URL) -> EPUBBook? {
        // 1. Find container.xml
        let containerURL = bookDirectory.appendingPathComponent("META-INF/container.xml")
        guard let containerParser = XMLParser(contentsOf: containerURL) else {
            print("Error: Could not find container.xml")
            return nil
        }
        
        let containerDelegate = ContainerParserDelegate()
        containerParser.delegate = containerDelegate
        containerParser.shouldProcessNamespaces = true
        containerParser.parse()
        
        guard let opfPath = containerDelegate.opfPath else {
            print("Error: Could not find OPF path in container.xml")
            return nil
        }
        
        // 2. Parse OPF
        let opfURL = bookDirectory.appendingPathComponent(opfPath)
        guard let opfParser = XMLParser(contentsOf: opfURL) else {
            print("Error: Could not find OPF file at \(opfURL)")
            return nil
        }
        
        opfParser.delegate = self
        self.spineRefs = []
        self.manifest = [:]
        self.currentTitle = ""
        self.currentAuthor = ""
        self.currentGenre = ""
        self.coverImageID = nil
        
        opfParser.parse()
        
        // 3. Construct Chapters
        let opfDirectory = opfURL.deletingLastPathComponent()
        var chapters: [EPUBChapter] = []
        
        for idref in spineRefs {
            if let href = manifest[idref] {
                // The href is relative to the OPF file
                // We need the full path or relative to bookDirectory?
                // Let's store the relative path from the bookDirectory
                
                // If opf is in OEBPS/, and href is Text/chap01.xhtml
                // Full path is bookDir/OEBPS/Text/chap01.xhtml
                
                // We want to store a path that the WebView can load.
                // Let's store the absolute URL for now or relative to bookDir.
                // Let's try to resolve it to an absolute path.
                let fullURL = opfDirectory.appendingPathComponent(href)
                let relativePath = fullURL.path.replacingOccurrences(of: bookDirectory.path + "/", with: "")
                
                chapters.append(EPUBChapter(title: "Chapter \(chapters.count + 1)", contentPath: relativePath))
            }
        }
        
        // 4. Find cover image
        var coverImageURL: URL?
        if let coverID = coverImageID, let coverHref = manifest[coverID] {
            coverImageURL = opfDirectory.appendingPathComponent(coverHref)
        } else {
            // Fallback: look for common cover image names
            for (id, href) in manifest {
                let lowercaseID = id.lowercased()
                let lowercaseHref = href.lowercased()
                if lowercaseID.contains("cover") || lowercaseHref.contains("cover") {
                    if href.hasSuffix(".jpg") || href.hasSuffix(".jpeg") || href.hasSuffix(".png") {
                        coverImageURL = opfDirectory.appendingPathComponent(href)
                        break
                    }
                }
            }
        }
        
        return EPUBBook(
            title: currentTitle.isEmpty ? "Unknown Title" : currentTitle,
            author: currentAuthor.isEmpty ? "Unknown Author" : currentAuthor,
            genre: currentGenre.isEmpty ? nil : currentGenre,
            coverImage: coverImageURL,
            chapters: chapters,
            directory: bookDirectory
        )
    }
    
    // MARK: - XMLParserDelegate for OPF
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            if let id = attributeDict["id"], let href = attributeDict["href"] {
                manifest[id] = href
            }
        } else if elementName == "itemref" {
            if let idref = attributeDict["idref"] {
                spineRefs.append(idref)
            }
        } else if elementName == "meta" {
            // Look for cover metadata: <meta name="cover" content="cover-image"/>
            if attributeDict["name"] == "cover", let content = attributeDict["content"] {
                coverImageID = content
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !data.isEmpty {
            if currentElement == "dc:title" {
                currentTitle += data
            } else if currentElement == "dc:creator" {
                currentAuthor += data
            } else if currentElement == "dc:subject" {
                if currentGenre.isEmpty {
                    currentGenre = data
                } else {
                    currentGenre += ", " + data
                }
            }
        }
    }
}

class ContainerParserDelegate: NSObject, XMLParserDelegate {
    var opfPath: String?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        // Check for rootfile element (case insensitive to handle namespace issues)
        if elementName.lowercased() == "rootfile" || qName?.lowercased() == "rootfile" {
            // Try both "full-path" (hyphenated) and "fullPath" (camelCase)
            if let fullPath = attributeDict["full-path"] ?? attributeDict["fullPath"] {
                opfPath = fullPath
                print("✅ Found OPF path: \(fullPath)")
            }
        }
    }
}
