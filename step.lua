local step = {}
local function get_table_number(tbl)
    assert(type(tbl) == "table", "not a table")
    local k = 0
    for i, v in pairs(tbl) do
        k = k + 1
    end
    return k
end
local function calc_times(p)
    if p >= 0.9 then
        return 1
    elseif p >= 0.75 then
        return 2
    elseif p >= 0.5 then
        return 3
    else
        return 4
    end
end
local function calc_prof(prof)
    return prof.correct / (prof.incorrect + prof.correct)
end
local function do_ch_to_en(words, prof, times, last)
    local choice = 0
    local can_be_choosen = {}
    -- 把符合条件的全部放到can_be_choosen这个table里面
    for i, v in pairs(words) do
        if times[v.word].cycle > 0 and times[v.word].ch2en == 0 then
            table.insert(can_be_choosen, i)
        end
    end
    local e = get_table_number(can_be_choosen)
    -- 没了
    if e < 1 then
        return last
    end
    choice = can_be_choosen[math.random(1, e)]
    if words[choice].word == last and e ~= 1 then
        return last -- 重复了
    end
    print(string.format("Translate TO ENGLISH!: %s", words[choice].meaning))
    ---@diagnostic disable-next-line: discard-returns
    local input = io.read()
    if input == words[choice].word then
        print("Correct!")
        local t = times[words[choice].word]
        t.ch2en = 1
        if t.ch2en + t.en2ch + t.choose == 3 then
            t.cycle = t.cycle - 1
            t.ch2en = 0
            t.en2ch = 0
            t.choose = 0
            if t.cycle == 0 then
                times.__left = times.__left - 1
            end
        end
        prof[words[choice].word].correct = prof[words[choice].word].correct + 1
        words[choice].prof = calc_prof(prof[words[choice].word])
    else
        print(string.format("Incorrect! The answer is %s", words[choice].word))
        prof[words[choice].word].incorrect = prof[words[choice].word].incorrect + 1
        words[choice].prof = calc_prof(prof[words[choice].word])
        times[words[choice].word].cycle = calc_times(words[choice].prof)
        local t = times[words[choice].word]
        t.ch2en = 0
        t.en2ch = 0
        t.choose = 0
    end
    return words[choice].word
end
local function do_en_to_ch(words, prof, times, last)
    local choice = 0
    local can_be_choosen = {}
    -- 把符合条件的全部放到can_be_choosen这个table里面
    for i, v in pairs(words) do
        if times[v.word].cycle > 0 and times[v.word].en2ch == 0 then
            table.insert(can_be_choosen, i)
        end
    end
    local e = get_table_number(can_be_choosen)
    -- 没了
    if e < 1 then
        return last
    end
    choice = can_be_choosen[math.random(1, e)]
    if words[choice].word == last and e ~= 1 then
        return last -- 重复了
    end
    print(string.format("Translate TO CHINESE(中文！): %s", words[choice].word))
    ---@diagnostic disable-next-line: discard-returns
    local input = io.read()
    if input == words[choice].meaning then
        print("Correct!")
        local t = times[words[choice].word]
        t.en2ch = 1
        if t.ch2en + t.en2ch + t.choose == 3 then
            t.cycle = t.cycle - 1
            t.ch2en = 0
            t.en2ch = 0
            t.choose = 0
            if t.cycle == 0 then
                times.__left = times.__left - 1
            end
        end
        prof[words[choice].word].correct = prof[words[choice].word].correct + 1
        words[choice].prof = calc_prof(prof[words[choice].word])
    else
        print(string.format("Incorrect! The answer is %s", words[choice].meaning))
        prof[words[choice].word].incorrect = prof[words[choice].word].incorrect + 1
        words[choice].prof = calc_prof(prof[words[choice].word])
        times[words[choice].word].cycle = calc_times(words[choice].prof)
        local t = times[words[choice].word]
        t.ch2en = 0
        t.en2ch = 0
        t.choose = 0
    end
    return words[choice].word
end
local function do_choose(words, prof, times, last)
    local choice = 0
    local can_be_choosen = {}
    local options = {} -- 选项
    -- 把符合条件的全部放到can_be_choosen这个table里面
    for i, v in pairs(words) do
        if times[v.word].cycle > 0 and times[v.word].choose == 0 then
            table.insert(can_be_choosen, i)
        end
    end

    local e = get_table_number(can_be_choosen)
    -- 没了
    if e < 1 then
        return last
    end


    choice = can_be_choosen[math.random(1, e)]

    for i, v in pairs(words) do -- 一些选项
        if i ~= choice then
            table.insert(options, i)
        end
    end
    if e == 0 then -- 没选项？
        -- 那就没办法了，算你过了这关
        local t = times[words[choice].word]
        t.choose = 1
        if t.ch2en + t.en2ch + t.choose == 3 then
            t.cycle = t.cycle - 1
            t.ch2en = 0
            t.en2ch = 0
            t.choose = 0
            if t.cycle == 0 then
                times.__left = times.__left - 1
            end
        end
        return last
    end

    if words[choice].word == last and e ~= 1 then
        return last -- 重复了
    end

    -- 做了这么多准备工作，终于可以开始出题了
    local option_choice = options[math.random(1, get_table_number(options))]
    local opt = { string.format("%s : %s", words[choice].word, words[choice].meaning), string.format("%s : %s",
        words[choice].word, words[option_choice].meaning) }
    local cor = math.random(1, 2) -- 正确的选项
    local real_out = {}
    real_out[cor] = opt[1]
    if cor == 2 then
        real_out[1] = opt[2]
    else
        real_out[2] = opt[2]
    end
    print(string.format("Which is correct: 1. %s 2. %s", real_out[1], real_out[2]))
    ---@diagnostic disable-next-line: discard-returns
    local input = io.read()
    local user_choice = tonumber(input)
    if user_choice == nil then
        user_choice = 3
    end

    if user_choice == cor then
        print("Correct!")
        local t = times[words[choice].word]
        t.choose = 1
        if t.ch2en + t.en2ch + t.choose == 3 then
            t.cycle = t.cycle - 1
            t.ch2en = 0
            t.en2ch = 0
            t.choose = 0
            if t.cycle == 0 then
                times.__left = times.__left - 1
            end
        end
        prof[words[choice].word].correct = prof[words[choice].word].correct + 1
        words[choice].prof = calc_prof(prof[words[choice].word])
    else
        print(string.format("Incorrect! The answer is %d", cor))
        prof[words[choice].word].incorrect = prof[words[choice].word].incorrect + 1
        words[choice].prof = calc_prof(prof[words[choice].word])
        times[words[choice].word].cycle = calc_times(words[choice].prof)
        local t = times[words[choice].word]
        t.ch2en = 0
        t.en2ch = 0
        t.choose = 0
        -- 排除法还不会吗？拷打
        prof[words[option_choice].word].incorrect = prof[words[option_choice].word].incorrect + 1
        words[option_choice].prof = calc_prof(prof[words[option_choice].word])
        times[words[option_choice].word].cycle = calc_times(words[option_choice].prof)
        t = times[words[option_choice].word]
        t.ch2en = 0
        t.en2ch = 0
        t.choose = 0
    end
    return words[choice].word
end

-- 只有当 中译英 英译中 还有选择题 全部答对时，这个单词才算完成一遍
function step.do_step(words, prof)
    local times = { __left = get_table_number(words), __number = get_table_number(words) }
    for i, v in pairs(words) do
        times[v.word] = {}
        times[v.word].cycle = calc_times(v.prof)
        times[v.word].ch2en = 0
        times[v.word].en2ch = 0
        times[v.word].choose = 0
    end
    local last = nil
    while 1 do
        if times.__left <= 0 then
            break
        end
        local mode = math.random(1, 3)
        print(string.format("progress: %g%%", (times.__number - times.__left) / times.__number * 100))
        if mode == 1 then
            last = do_ch_to_en(words, prof, times, last)
        elseif mode == 2 then
            last = do_en_to_ch(words, prof, times, last)
        elseif mode == 3 then
            last = do_choose(words, prof, times, last)
        end
    end
    print("Congratulations! You have successfully memorized a round!")
end

return step
