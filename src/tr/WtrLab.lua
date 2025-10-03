--[[
    Wtr-lab.com Extension for Shosetsu (Lua) - Corrected for Scope
--]]

-- Meta Information
local name = "Wtr-lab.com"
local version = "1.0.2" -- Incremented version for the fix
local id = 133701
local lang = "tr"
local source = "https://wtr-lab.com"

-- Helper function to parse novel items from a list
local function parseNovel(element)
    local novel = {}
    novel.title = element:select("h5 a"):text()
    novel.url = element:select("h5 a"):attr("href")
    novel.cover = element:select("img"):attr("src")
    return novel
end

-- Fetch popular novels
-- FIXED: Added 'local' keyword
local function getPopular(page)
    local url = source .. "/seriler?order=popularity&page=" .. page
    local response = http.get(url)
    local document = html.parse(response)
    local novels = {}
    for i, el in ipairs(document:select(".card.novel-card")) do
        table.insert(novels, parseNovel(el))
    end
    return novels
end

-- Fetch latest updated novels
-- FIXED: Added 'local' keyword
local function getLatest(page)
    local url = source .. "/seriler?order=update&page=" .. page
    local response = http.get(url)
    local document = html.parse(response)
    local novels = {}
    for i, el in ipairs(document:select(".card.novel-card")) do
        table.insert(novels, parseNovel(el))
    end
    return novels
end

-- Search for novels
-- FIXED: Added 'local' keyword
local function search(query, page)
    local url = source .. "/seriler?q=" .. http.urlEncode(query) .. "&page=" .. page
    local response = http.get(url)
    local document = html.parse(response)
    local novels = {}
    for i, el in ipairs(document:select(".card.novel-card")) do
        table.insert(novels, parseNovel(el))
    end
    return novels
end

-- Fetch novel details
-- FIXED: Added 'local' keyword
local function getNovel(url)
    local response = http.get(url)
    local document = html.parse(response)
    local novel = {}

    novel.title = document:select("h1.novel-title"):text()
    novel.cover = document:select(".novel-cover img"):attr("src")
    local authorElement = document:select("a[href*='/yazar/'], a[href*='/cevirmen/']"):first()
    if authorElement then
        novel.author = authorElement:text()
    end
    novel.summary = document:select("div.novel-summary p"):text()
    novel.genres = {}
    for i, el in ipairs(document:select("div.novel-genres a")) do
        table.insert(novel.genres, el:text())
    end
    return novel
end

-- Fetch chapters for a novel
-- FIXED: Added 'local' keyword
local function getChapters(url)
    local chapter_url = url
    if not string.find(url, "/bolumler$") then
       chapter_url = url .. "/bolumler"
    end

    local response = http.get(chapter_url)
    local document = html.parse(response)
    local chapters = {}
    
    for i, el in ipairs(document:select(".chapter-list a")) do
        local chapter = {}
        chapter.name = el:text()
        chapter.url = el:attr("href")
        table.insert(chapters, chapter)
    end
    
    local reversed_chapters = {}
    for i = #chapters, 1, -1 do
        table.insert(reversed_chapters, chapters[i])
    end

    return reversed_chapters
end

-- Fetch chapter content
-- FIXED: Added 'local' keyword
local function getChapterContent(url)
    local response = http.get(url)
    local document = html.parse(response)
    local content = document:select("#chapter-content"):html()
    return content
end

-- Expose public functions to Shosetsu
-- This return table is how the local functions are made available to the app
return {
    -- METADATA
    name = name,
    version = version,
    id = id,
    lang = lang,
    source = source,

    -- NOVEL LISTS
    getPopular = getPopular,
    getLatest = getLatest,
    search = search,

    -- NOVEL DETAILS
    getNovel = getNovel,
    getChapters = getChapters,
    getChapterContent = getChapterContent
}
