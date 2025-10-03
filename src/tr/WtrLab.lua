--[[
    Wtr-lab.com Extension for Shosetsu (Lua) - Verified & Corrected
--]]

-- Meta Information
local name = "Wtr-lab.com"
local version = "1.0.1" -- Incremented version
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
function getPopular(page)
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
function getLatest(page)
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
function search(query, page)
    -- URL encode the query to handle spaces and special characters
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
function getNovel(url)
    local response = http.get(url)
    local document = html.parse(response)
    local novel = {}

    novel.title = document:select("h1.novel-title"):text()
    novel.cover = document:select(".novel-cover img"):attr("src")
    -- Corrected: Find author or translator and combine selectors
    local authorElement = document:select("a[href*='/yazar/'], a[href*='/cevirmen/']"):first()
    if authorElement then
        novel.author = authorElement:text()
    end
    -- Corrected: The summary is inside a <p> tag within the div
    novel.summary = document:select("div.novel-summary p"):text()
    novel.genres = {}
    -- Corrected: More specific selector for genres/tags
    for i, el in ipairs(document:select("div.novel-genres a")) do
        table.insert(novel.genres, el:text())
    end
    return novel
end

-- Fetch chapters for a novel
function getChapters(url)
    -- Append the chapters path to the novel URL
    local chapter_url = url
    if not string.find(url, "/bolumler$") then
       chapter_url = url .. "/bolumler"
    end

    local response = http.get(chapter_url)
    local document = html.parse(response)
    local chapters = {}
    
    -- Corrected: More specific selector for chapter links
    for i, el in ipairs(document:select(".chapter-list a")) do
        local chapter = {}
        chapter.name = el:text()
        chapter.url = el:attr("href")
        table.insert(chapters, chapter)
    end
    
    -- Chapters are listed newest to oldest, so they must be reversed
    local reversed_chapters = {}
    for i = #chapters, 1, -1 do
        table.insert(reversed_chapters, chapters[i])
    end

    return reversed_chapters
end

-- Fetch chapter content
function getChapterContent(url)
    local response = http.get(url)
    local document = html.parse(response)
    -- This selector is correct for the site structure
    local content = document:select("#chapter-content"):html()
    return content
end

-- Expose public functions to Shosetsu
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
