require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    ServiceRate = 0.3

    StoryModeEvents =
    {
        Init_GC = Global_Story,
        Update = Update,
        Flush = Flush,
    }

    Starting_Units = nil

    Filter_System = nil

    Tech_Theft = nil

    Global_Planet_Table = nil

    Player = nil

end

function Global_Story(message)
    if  message == OnEnter then 

        Player = Find_Human_Player()

        Starting_Units = require("Starting_Units") 

        Starting_Units:Start()

        if Starting_Units:Is_Finished() then
            Story_Event("Spawning_Done")

            Set_Next_State("Flush")
        end
    end
end

function Update(message)
    if message == OnUpdate then
        
    end
end

function Flush(message)
    if message == OnEnter then
        Set_Next_State("Update")
    end
end
