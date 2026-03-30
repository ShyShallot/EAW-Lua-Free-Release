---@class Header
---@field Text string TEXT_ID
---@field Color table Defaults to white. Format {r=255,b=255,g=255}
---@field Var any Only Objects and Player will properly work
---@field Time number Time in seconds till text disappears
---@field private Time_Added number 

---@class Body
---@field Text string TEXT_ID
---@field Color table Defaults to white. Format {r=255,b=255,g=255}
---@field Var any Only Objects and Player will properly work
---@field Time number Time in seconds till text disappears
---@field Teletype boolean Is Text typed in over time
---@field private Time_Added number
---@field private Shown boolean

---@class Footer
---@field Text string TEXT_ID
---@field Color table Defaults to white. Format {r=255,b=255,g=255}
---@field Var any Only Objects and Player will properly work
---@field Time number Time in seconds till text disappears
---@field private Time_Added number 

---@class Display_Handler
Display_Handler = {
    ---@type Header[]
    Headers = {

    },
    ---@type Body[]
    Body = {

    },
    ---@type Body[]
    Footer = {

    },
}


---@param string string
---@param color? table
---@param var? any
---@param time? number
function Display_Handler:Add_Header(string, color, var, time)
    if type(string) ~= "string" then
        return
    end

    if color == nil then
        color = {r=255,b=255,g=255}
    end

    if color.r == nil then
        color.r = 255
    end

    if color.b == nil then
        color.b = 255
    end

    if color.g == nil then
        color.g = 255
    end

    if type(time) ~= "number" then
        time = -1
    end

    local is_invalid = false

    for _, sHeader in pairs(self.Headers) do
        if sHeader.Text == string then
            if sHeader.Var ~= var and var ~= nil then
                sHeader.Var = var
            end
            is_invalid = true
            break
        end
    end

    if is_invalid then
        return
    end
    

    table.insert(self.Headers, {Text = string, Color = color, Var = var, Time = time, Time_Added = GetCurrentTime.Galactic_Time()})
end

---@param string string
---@param color? table
---@param var? any
---@param time? number
function Display_Handler:Add_Footer(string, color, var, time)
    if type(string) ~= "string" then
        return
    end

    if color == nil then
        color = {r=255,b=255,g=255}
    end

    if color.r == nil then
        color.r = 255
    end

    if color.b == nil then
        color.b = 255
    end

    if color.g == nil then
        color.g = 255
    end

    if type(time) ~= "number" then
        time = -1
    end

    local is_invalid = false

    for _, sHeader in pairs(self.Footer) do
        if sHeader.Text == string then
            is_invalid = true
            break
        end
    end

    if is_invalid then
        return
    end
    

    table.insert(self.Footer, {Text = string, Color = color, Var = var, Time = time, Time_Added = GetCurrentTime.Galactic_Time()})
end

---@param string string
---@param time number
---@param teletype? boolean
---@param color? table
---@param var? any
function Display_Handler:Add_Body(string, time, teletype, color, var)
    if type(string) ~= "string" then
        return
    end

    if type(time) ~= "number" then
        time = 5
    end

    if teletype ~= true then
        teletype = false
    end

    if color == nil then
        color = {r=255,b=255,g=255}
    end

    if color.r == nil then
        color.r = 255
    end

    if color.b == nil then
        color.b = 255
    end

    if color.g == nil then
        color.g = 255
    end

    local is_invalid = false

    for _, sBody in pairs(self.Body) do
        if sBody.Text == string then
            is_invalid = true
            break
        end
    end

    if is_invalid then
        return
    end

    table.insert(self.Body, {Text = string, Color = color, Var = var, Time = time, Teletype = teletype, Time_Added = GetCurrentTime.Galactic_Time(), Shown = false})
end

---@private
function Display_Handler:Remove_Text()

    DebugMessage("%s -- Clearing Text", tostring(Script))

    for _, Header in pairs(self.Headers) do
        Remove_Screen_Text(Header.Text)
    end

    Remove_Screen_Text(" ")
    Remove_Screen_Text("--------------------------")
    Remove_Screen_Text("  ")

    for _, Body in pairs(self.Body) do
        DebugMessage("%s -- Clearing: %s", tostring(Script), tostring(Body.Text))
        Remove_Screen_Text(Body.Text)
    end

    for _, Footer in pairs(self.Footer) do
        Remove_Screen_Text(Footer.Text)
    end
end

function Display_Handler:Process()

    self:Remove_Text()

    local Header_Length = tableLength(self.Headers)

    if Header_Length > 0 then
        for i=1, Header_Length do
            local Header = self.Headers[i]
            if Header ~= nil then
                local Is_Header_Valid = false

                if Header.Time > -1 then
                    if Header.Time_Added + Header.Time >= GetCurrentTime.Galactic_Time() then
                        Is_Header_Valid = true
                    end
                end

                if Header.Time == -1 then
                    Is_Header_Valid = true
                end
                
                if Is_Header_Valid then
                    Show_Screen_Text(Header.Text, Header.Var, -1, Header.Color, false)
                else
                    table.remove(self.Headers, i)
                end
            end
        end
    end

    Show_Screen_Text(" ", nil, -1)
    Show_Screen_Text("--------------------------", nil, -1)
    Show_Screen_Text("  ", nil, -1)

    local Body_Index = 1

    while Body_Index <= tableLength(self.Body) do
        local Body = self.Body[Body_Index]
        if Body ~= nil then
            DebugMessage("%s -- Adding Body %s", tostring(Script), tostring(Body.Text))

            local Is_Body_Valid = false

            if Body.Time > -1 then
                DebugMessage("%s -- Body is not infinite. Current Time: %s, Time Added: %s, Lasts: %s", tostring(Script), tostring(GetCurrentTime.Galactic_Time()), tostring(Body.Time_Added), tostring(Body.Time))
                if Body.Time_Added + Body.Time > GetCurrentTime.Galactic_Time() then
                    DebugMessage("%s -- Body is Valid", tostring(Script))
                    Is_Body_Valid = true
                end
            end

            if Body.Time == -1 then
                DebugMessage("%s -- Body is Infinite", tostring(Script))
                Is_Body_Valid = true
            end

            if Is_Body_Valid then
                DebugMessage("%s -- Body is Valid", tostring(Script))
                if Body.Shown then
                    Body.Teletype = false
                else
                    Body.Shown = true
                end

                Show_Screen_Text(Body.Text, Body.Var, -1, Body.Color, Body.Teletype)

                Body_Index = Body_Index + 1
            else
                DebugMessage("%s -- Removing Body", tostring(Script))
                Remove_Screen_Text(Body.Text)
                table.remove(self.Body, Body_Index)
            end
        end
    end

    local Footer_Length = tableLength(self.Footer)

    if Footer_Length > 0 then
        for i=1, Footer_Length do
            local Footer = self.Footer[i]
            if Footer ~= nil then
                local Is_Footer_Valid = false

                if Footer.Time > -1 then
                    if Footer.Time_Added + Footer.Time >= GetCurrentTime.Galactic_Time() then
                        Is_Footer_Valid = true
                    end
                end

                if Footer.Time == -1 then
                    Is_Footer_Valid = true
                end
                
                if Is_Footer_Valid then
                    Show_Screen_Text(Footer.Text, Footer.Var, -1, Footer.Color, false)
                else
                    table.remove(self.Footer, i)
                end
            end
        end
    end
end

function Display_Handler:Remove_Header(text)
    if type(text) ~= "string" then
        return
    end

    local Header_Length = tableLength(self.Headers)

    for i=1, Header_Length do
        local Header = self.Headers[i]

        if Header ~= nil then
            if Header.Text == text then
                table.remove(self.Headers,i)
                Remove_Screen_Text(text)
                break
            end
        end
    end
end

function Display_Handler:Remove_Footer(text)
    if type(text) ~= "string" then
        return
    end

    local Header_Length = tableLength(self.Footer)

    for i=1, Header_Length do
        local Header = self.Footer[i]

        if Header ~= nil then
            if Header.Text == text then
                table.remove(self.Footer,i)
                break
            end
        end
    end
end

---@param text string
---@param var any|nil
---@param time_to_show number
---@param color? table
---@param teletype? boolean
function Show_Screen_Text(text, var, time_to_show, color, teletype) -- inspired by the Thrawns Revenge Team but slightly modified to fit our purpose
    
    local Plot = Get_Story_Plot("XML\\Setup_Generic.xml")

    if Plot == nil then
        return
    end

    local text_event = Plot.Get_Event("Show_Screen_Text")

    if text_event == nil then
        return
    end

    if type(text) ~= "string" then
        return
    end

    local colorstring = ""

    if color == nil then
        color = {r = 255, g = 255, b = 255}
    end
    
    if color then
        colorstring = color.r .. " " .. color.g .. " " .. color.b
    end

    local use_teletype = 1
    if teletype == false then
        use_teletype = 0
    end

    if var == nil then
        var = ""
    end

    DebugMessage("%s -- Running Screen Text for Output: %s", tostring(Script), tostring(text))

    text_event.Set_Reward_Parameter(0, text)
    text_event.Set_Reward_Parameter(1,tostring(time_to_show)) -- time in seconds
    text_event.Set_Reward_Parameter(2, var) -- parameter we dont care about
    text_event.Set_Reward_Parameter(3, "")
    text_event.Set_Reward_Parameter(4, use_teletype) -- whether or not the text is slowly typed out or is just shown
    text_event.Set_Reward_Parameter(5, colorstring) -- for color
    text_event.Set_Reward_Parameter(6, "System")
    Story_Event("SHOW_SCREEN_TEXT")
end

function Remove_Screen_Text(text)
    local Plot = Get_Story_Plot("XML\\Setup_Generic.xml")

    if Plot == nil then
        return
    end

    local text_event = Plot.Get_Event("Show_Screen_Text")

    if text_event == nil then
        return
    end

    if type(text) ~= "string" then
        return
    end

    text_event.Set_Reward_Parameter(0, text)
    text_event.Set_Reward_Parameter(3, "remove")
    Story_Event("SHOW_SCREEN_TEXT")
end