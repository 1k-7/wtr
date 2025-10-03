--[[
    Wtr-lab.com Extension for Shosetsu (Lua) - API Compliance Fix
--]]

-- Meta Information
local name = "Wtr-lab.com"
local version = "1.0.4" -- Incremented version for API fix
local id = 133701
local lang = "tr"
local source = "https://wtr-lab.com"

-- This is a helper function to parse novel items from a list (like Popular or Search)
-- It remains local and is not exposed to the app directly.
local function parseNovelListItem(element)
    local novel = {}
    novel.title = element:select("h5 a"):text()
    novel.url = element:select("h5 a"):attr("href")
    novel.cover = element:select("img"):attr("src")
    return novel
end

-- These functions fetch the lists of novels.
-- They are referenced by the `listings` function below.
local function getPopular(page)
    local url = source .. "/seriler?order=popularity&page=" .. page
    local response = http.get(url)
    local document = html.parse(response)
    local novels = {}
    for i, el in ipairs(document:select(".card.novel-card")) do
        table.insert(novels, parseNovelListItem(el))
    end
    return novels
end

local function getLatest(page)
    local url = source .. "/seriler?order=update&page=" .. page
    local response = http.get(url)
    local document = html.parse(response)
    local novels = {}
    for i, el in ipairs(document:select(".card.novel-card")) do
        table.insert(novels, parseNovelListItem(el))
    end
    return novels
end

-- Search function - the name 'search' appears to be standard
local function search(query, page)
    local url = source .. "/seriler?q=" .. http.urlEncode(query) .. "&page=" .. page
    local response = http.get(url)
    local document = html.parse(response)
    local novels = {}
    for i, el in ipairs(document:select(".card.novel-card")) do
        table.insert(novels, parseNovelListItem(el))
    end
    return novels
end

-- REQUIRED: Renamed from getNovel to parseNovel.
-- This function gets the details for a single novel.
local function parseNovel(url)
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

-- The name 'getChapters' appears to be standard
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

-- REQUIRED: Renamed from getChapterContent to getPassage.
-- This function gets the text content of a single chapter.
local function getPassage(url)
    local response = http.get(url)
    local document = html.parse(response)
    local content = document:select("#chapter-content"):html()
    return content
end

-- REQUIRED: This function tells the app which browsable lists are available.
local function listings()
    return {
        { name = "Popular", value = "getPopular" },
        { name = "Latest", value = "getLatest" }
    }
end

-- This final table returns all the functions with the exact keys the app expects.
return {
    -- METADATA
    name = name,
    version = version,
    id = id,
    lang = lang,
    source = source,

    -- REQUIRED API KEYS
    listings = listings,
    parseNovel = parseNovel,
    getPassage = getPassage,
    
    -- STANDARD API KEYS
    search = search,
    getChapters = getChapters,
    
    -- Functions referenced by listings() must also be returned
    -- so the app can find and call them.
    getPopular = getPopular,
    getLatest = getLatest
}
