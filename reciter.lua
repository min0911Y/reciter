local function get_table_number(tbl)
    assert(type(tbl) == "table", "not a table")
    local k = 0
    for i, v in pairs(tbl) do
        k = k + 1
    end
    return k
end
-- 创建熟练度的配置

local json = require("json")
local step = require("step")
local config = io.open('config.json', "r")
local words_prof_file = io.open("prof.json", "r")
local ret, prof -- prof: 单词的准确率
local flag = 0

if words_prof_file ~= nil then
    ret, prof = pcall(json.decode, words_prof_file:read("a"))
else
    flag = 1
    words_prof_file = io.open("prof.json", "w")
    prof = {}
end
if flag == 0 then
    assert(words_prof_file)
    words_prof_file:close()
    words_prof_file = io.open("prof.json", "w")
    if ret == false or type(prof) ~= "table" then
        prof = {}
    end
end
assert(words_prof_file)

assert(config, "open errror")
local reciter_config = json.decode(config:read("a"))
assert(reciter_config, "parse error")
config:close()


-- 这个words变量存储一会会拿出来抽的单词
local words = {}
for i, v in pairs(reciter_config.recite) do
    for k, v1 in pairs(reciter_config[v]) do
        table.insert(words, v1)
    end
end
for i, v in pairs(words) do
    if prof[v.word] == nil then
        prof[v.word] = { correct = 0, incorrect = 0 }
        v.prof = 0
    else
        if prof[v.word].correct + prof[v.word].incorrect == 0 then
            v.prof = 0
        else
            v.prof = prof[v.word].correct / (prof[v.word].correct + prof[v.word].incorrect)
        end
    end
end
print("reciter v0.0.1 type `help` to get help")
while 1 do
    io.write("Console>>> ")
    local inp = io.read()
    if inp == "recite" then
        pcall(step.do_step, words, prof)
    elseif inp == "exit" then
        break
    elseif inp == "list_prof" then
        for i, v in pairs(words) do
            print(v.word, string.format("%g%%", v.prof * 100))
        end
    elseif inp == "help" then
        print("recite 进行一轮背诵")
        print("exit 退出")
        print("list_prof 查看各个单词熟练度")
        print("help 显示此命令")
    end
end

words_prof_file:write(json.encode(prof))
words_prof_file:close()
