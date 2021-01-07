if ModeSelector == nil then
	ModeSelector = {}
	ModeSelector.__index = HeroSelection
end

function ModeSelector:Start()
	--Listen for mode selected event
	ModeSelector.listener = CustomGameEventManager:RegisterListener( "mode_selected", ModeSelector.ModeSelected )
end

function ModeSelector:ModeSelected( event )

    print("mode selected ",event.mode)

    if event.mode == "storyMode" then
        STORY_MODE = true
        NORMAL_MODE = false
    elseif event.mode == "normalMode" then
        STORY_MODE = false
        NORMAL_MODE = true
    end
end